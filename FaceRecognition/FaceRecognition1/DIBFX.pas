//****************************************************************************//
//***** INCLUSION DE DIBFX dans DIBULTRA.PAS : EFFET SPECIAUX OPTIMISES  *****//
//***** SE REPORTER A DIBULTRA.PAS POUR D'AUTRES INFORMATIONS            *****//
//****************************************************************************//
// Version 1.4   Copyright/CopyLeft GPL (C) 1999 LEON S�bastien               //
//                                                                            //
// ## History : ##                                                            //
// Version 1.0 : (1/1999)                                                     //
// Version 1.1 : (4/1999) AlphaChanelBlit support 16 AlphaLevels              //
//               Fix a CreateFromFile Bug for 15, 16, 24 & 32 Bpp             //
// Version 1.2 : (5/1999)LZH for UDc ; AlphaChanelBlit support 33 AlphaLevels //
// Version 1.3 : (5/1999)AlphaBlit effect (support 33 AlphaLevels)            //
// Version 1.4 : (6/1999)Best support for 24 bpp UDC compressed DIBs          //
//                                                                            //
//****************************************************************************//

Const
  MaskVRB = $07E0F81F; // Fichu masque 16 bpp sur 2 pixels
  MaskRB  = $F81F;     // Fichu masque 16 bpp sur 1 pixel

//############################################################
//###########  ALPHA BLIT A 33 NIVEAUX DE DENSITE  ###########
//###########  S�bastien LEON CopyLeft GNU 5/1999  ###########
//############################################################


procedure TDIBUltra.AlphaChanelBlit(Dest : TDIBUltra; x, y, Num : integer);

{$IFDEF NEVER_DEFINED}
  ######### ALPHA BLITTING ROUTINE : COMMON USAGE ##########
  ##                                                      ##
  ## Cette routine fonctionne de la mani�re suivante :    ##
  ## L'' appel se fait par exemple :                      ##
  ##       Src.AlphaChanelBlit(Dest, x, y, Num)           ##
  ##                                                      ##
  ## O� Src est DIBUltra charg�e par une image *.udc      ##
  ##    (une UltraDIB normale � laquelle on a             ##
  ##     ensuite affect� un masque Alpha 32 niveaux)      ##
  ## O� Dest est DIBUltra                                 ##
  ## O� x est la position de d�part en x du Blit          ##
  ## O� y est la position de d�part en y du Blit          ##
  ## (pour x et y = 0 on se place � la premi�re ligne et  ##
  ##  � la premi�re colonne de la destination.)           ##
  ## O� Num est le num�ro de couche Alpha (Animation)     ##
  ##                                                      ##
  ## En fonction des valeurs donn�es par le pilote Alpha  ##
  ## fourni par la Src, les pixels sources vont se m�ler  ##
  ## � ceux de l''image destination.                      ##
  ## L''image de Destination DOIT �tre de TDUPixelFormat  ##
  ## = � DUpf16.                                          ##
  ## Cette version supporte 33 niveaux de transparence.   ##
  ## La transparence 0 restitue enti�rement la valeur du  ##
  ## pixel de l''image de Dest tandis qu''une transp. de  ##
  ## 32 affecte � Dest la valeur exacte du pixel de Src.  ##
  ##                                                      ##
  ## Cette impl�mentation ne g�re pas encore le clipping  ##
  ## ni l''animation : on veuilleras donc � ce que Src    ##
  ## plac�e en x,y tienne dans Dest et que Num = 1.       ##
  ##                                                      ##
  ##########################################################
{$ENDIF}

var
  BorneOK   : Boolean;
  // For ASM Implementation
  AdrDest   : Pointer; // Adresse du d�but de ligne de l'image destination
  AdrSrc    : Pointer; // Adresse du d�but de ligne de l'image source
  AdrAlpha  : Pointer; // Adresse du pilote Alpha
  AdrDtInc  : LongInt; // Incr�ment pour passer d'une ligne n en n+1 (== Width_b) pour l'img Dest
  AdrSrInc  : LongInt; // Incr�ment pour passer d'une ligne n en n+1 (== Width_b) pour l'img Src
  ESI, EDI  : LongInt; // Sauvegarde Registres
  EBX       : LongInt; // Sauvegarde Registres
  RBGTmp    : LongInt;
  GRBTmp    : LongInt;
  Tmp1      : LongInt;
  MulA, MulB: LongInt;

Begin
  If (Alpha=nil) Then Raise Exception.Create('Cette DIBUltra ne supporte pas le traitement Alpha.');
  If (Num<>1) Then Raise Exception.Create('AlphaBlit ne supporte pas encore l''animation. (Num doit �tre = 1)');
  If (Self.PixelFormat<>DUpf16) Then Raise Exception.Create('La DIBUltra a afficher par filtre Alpha doit �tre une image � 16 Bpp !');
  If (Dest.PixelFormat<>DUpf16) Then Raise Exception.Create('L''image en Destination doit �tre une image � 16 Bpp !');
  // V�rification des bornes :
  BorneOK := (x>=0) AND (y>=0) AND ((x+DIBWidth) <= Dest.Width) AND ((y+DIBHeight) <= Dest.Height);
  If (Not BorneOK) Then Raise Exception.Create('Le clipping n''est pas encore support�.'#13'Le sprite doit tenir enti�rement dans l''image de destination.');
  // OK, Initialisation des Adresses
  AdrDest  := P(I(Dest.Scanline[y]) + 2*x);
  AdrSrc   := DIBAdr;
  AdrAlpha := P(I(Alpha) + SizeOf(TAlphaMaskHeader));
  AdrDtInc := (Dest.ByteWidth);
  AdrSrInc := DIBWidth_b;
  ASM
  MOV  &ESI, ESI         // Save Register
  MOV  &EDI, EDI
  MOV  &EBX, EBX

  MOV  ESI,  AdrSrc      // Initialisation des pointeurs
  MOV  EDI,  AdrDest
  MOV  EBX,  AdrAlpha
  SUB  EBX,  2           // On lira la valeur suivante

  @DoItAgain:            // Boucle globale

  ADD   EBX, 2           // D�placement du pointeur sur le pilote Alpha
  MOV   AX,  [EBX]       // Lecture du pilote Alpha \ AH = Densit� | AL = R�p�tition
  AND   EAX, $FFFF       // Lev�e du Zero Flag si AX=0
  JZ    @EOL             // Si Valeur = 0 => Goto @EndOfLine:
  MOV   ECX, EAX         // Initialisation du compteur de r�p�tition
  AND   ECX, $FF         // On ne garde que la valeur de r�p�tition
  SHR   EAX, 8           // D'une pierre deux coups : EAX=Densit� et lev�e du flag Z
  JZ    @TRANSP          // Si Densit� = 0 alors transparence totale
  CMP   EAX, $20         // Test de la densit� : a-t-on une densit� de 32 ?
  JZ    @OPAQUE          // Si Densit� = 32 alors opacit� totale
  MOV   MulA, EAX        // Stockage du Multiplicateur A
  SUB   EAX, 32          // compl�ment du ...
  NEG   EAX              // ... facteur multiplicateur
  MOV   MulB, EAX        // Stockage du Multiplicateur B


  @NORMAL: // ***** TRAITEMENT DES PIXELS DE DENSITE INCLUSE ENTRE 1 ET 14
  SHR   ECX, 1           // On divise le compteur par deux
  JNC   @NORMALPAIR      // Si il �tait pair, on traite les pixels 2 par 2

  // RAPPEL : Pixel au format 16Bpp : RRRRRVVV VVVBBBBB ; Masque  : $F800 $07E0 $001F
  // Traitement du pixel source source
    MOV   AX, [ESI]        // Recopie d'un pixel From Source
    MOV   EDX, EAX         // Copie en DX
    AND   EAX, MaskRB      // On garde le rouge et le bleu
    AND   EDX, Not MaskRB  // On garde le vert
    SHR   EDX, 5           // ## DIVISION PAR 32 ##
    MOV   RBGTmp, EDX      // Sauvegarde en RBGTmp
    MUL   MulA             // ## MULTIPLICATION ##
    MOV   GRBTmp, EAX      // Sauvegarde en GRBTmp
    MOV   EAX,  RBGTmp     // Rechargement du Vert
    MUL   WORD PTR [MulA]  // ## MULTIPLICATION ##
    MOV   RBGTmp, EAX      // Sauvegarde en RBGTmp
    // Traitement du Pixel Destination
    MOV   EAX, [EDI]       // Recopie d'un pixel From Dest
    MOV   EDX, EAX         // Copie en DX
    AND   EAX, MaskRB      // On garde le rouge et le bleu
    AND   EDX, Not MaskRB  // On garde le vert
    SHR   EDX, 5           // ## DIVISION PAR 32 ##
    MOV   Tmp1, EDX        // Sauvegarde en Tmp1
    MUL   MulB             // ## MULTIPLICATION ##
    ADD   GRBTmp, EAX      // Addition avec la valeur sauvegard�e en GRBTmp
    MOV   EAX, Tmp1        // Rechargement du Vert
    MUL   WORD PTR [MulB]  // ## MULTIPLICATION ##
    ADD   EAX, RBGTmp      // Addition avec la valeur sauvegard�e en RBGTmp
    MOV   EDX, GRBTmp      // Rechargement de la valeur interm�diaire
    SHR   EDX, 5           // ## DIVISION PAR 32 ##
    AND   EDX, MaskRB      // On garde le rouge et le bleu
    AND   EAX, Not MaskRB  // On garde le vert
    OR    EAX, EDX         // Assemblage des RVB
    MOV   [EDI], AX        // Recopie du pixel vers la destination

    ADD  ESI, 2            // D�placement du pointeur Source d'un pixel
    ADD  EDI, 2            // D�placement du pointeur Destination d'un pixel
    CMP  ECX, 0            // C'est fini ?
    JZ   @DoItAgain        // Oui le compteur est � z�ro | Non : on traite 2 par 2

  @NORMALPAIR:             // On traite les pixels deux par deux
  // RAPPEL : Pixel au format 16Bpp : RRRRRVVV VVVBBBBB ; Masque  : $F800 $07E0 $001F
  // Traitement du pixel source source
    MOV   EAX, [ESI]       // Recopie d'un pixel From Source
    MOV   EDX, EAX         // Copie en DX
    AND   EAX, MaskVRB     // On garde le rouge et le bleu
    AND   EDX, Not MaskVRB // On garde le vert
    SHR   EDX, 5           // ## DIVISION PAR 32 ##
    MOV   RBGTmp, EDX      // Sauvegarde en RBGTmp
    MUL   MulA             // ## MULTIPLICATION ##
    MOV   GRBTmp, EAX      // Sauvegarde en GRBTmp
    MOV   EAX,  RBGTmp     // Rechargement du Vert
    MUL   MulA             // ## MULTIPLICATION ##
    MOV   RBGTmp, EAX      // Sauvegarde en RBGTmp
    // Traitement du Pixel Destination
    MOV   EAX, [EDI]       // Recopie d'un pixel From Dest
    MOV   EDX, EAX         // Copie en DX
    AND   EAX, MaskVRB     // On garde le rouge et le bleu
    AND   EDX, Not MaskVRB // On garde le vert
    SHR   EDX, 5           // ## DIVISION PAR 32 ##
    MOV   Tmp1, EDX        // Sauvegarde en Tmp1
    MUL   MulB             // ## MULTIPLICATION ##
    ADD   GRBTmp, EAX      // Addition avec la valeur sauvegard�e en GRBTmp
    MOV   EAX, Tmp1        // Rechargement du Vert
    MUL   MulB             // ## MULTIPLICATION ##
    ADD   EAX, RBGTmp      // Addition avec la valeur sauvegard�e en RBGTmp
    MOV   EDX, GRBTmp      // Rechargement de la valeur interm�diaire
    SHR   EDX, 5           // ## DIVISION PAR 32 ##
    AND   EDX, MaskVRB     // On garde le rouge et le bleu
    AND   EAX, Not MaskVRB // On garde le vert
    OR    EAX, EDX         // Assemblage des RVB
    MOV   [EDI], EAX       // Recopie du pixel vers la destination

    ADD  ESI, 4            // D�placement du pointeur Source de 2 pixels
    ADD  EDI, 4            // D�placement du pointeur Destination de 2 pixels
    LOOP @NORMALPAIR       // C'est fini ?
  JMP @DoItAgain           // On repart ...

  @TRANSP: // ***** TRAITEMENT DES PIXELS DE DENSITE ZERO
  SHR  ECX, 1           // On divise le compteur par deux
  JNC  @TRANSPAIR       // Si il �tait pair, on traite les pixels 2 par 2
    ADD  ESI, 2         // D�placement du pointeur Source
    ADD  EDI, 2         // D�placement du pointeur Destination
    CMP  ECX, 0         // C'est fini ?
    JZ   @DoItAgain     // Oui le compteur est � z�ro
  @TRANSPAIR:           // On traite les pixels deux par deux
    ADD  ESI, 4         // D�placement du pointeur Source de 2 pixels
    ADD  EDI, 4         // D�placement du pointeur Destination de 2 pixels
    LOOP @TRANSPAIR     // C'est fini ?
  JMP @DoItAgain        // On repart ...

  @OPAQUE: // ***** TRAITEMENT DES PIXELS DE DENSITE TOTALE
  SHR  ECX, 1           // On divise le compteur par deux
  JNC  @OPAQPAIR        // Si il �tait pair, on traite les pixels 2 par 2
    MOV  AX, [ESI]      // Recopie d'un pixel From Source
    MOV  [EDI], AX      // Recopie d'un pixel To Dest
    ADD  ESI, 2         // D�placement du pointeur Source d'1 pixel
    ADD  EDI, 2         // D�placement du pointeur Destination d'1 pixel
    CMP  ECX, 0         // C'est fini ?
    JZ   @DoItAgain     // Oui le compteur est � z�ro
  @OPAQPAIR:            // On traite les pixels deux par deux
    MOV  EAX, [ESI]     // Recopie de 2 pixels From Source
    MOV  [EDI], EAX     // Recopie de 2 pixels To Dest
    ADD  ESI, 4         // D�placement du pointeur Source de 2 pixels
    ADD  EDI, 4         // D�placement du pointeur Destination de 2 pixels
    LOOP @OPAQPAIR      // C'est fini ?
  JMP @DoItAgain        // Allez, c'est pas fini !

  @EOL:    // ***** TRAITEMENT D'UN CODE END OF LINE
  MOV  AX,  [EBX+2]     // Lecture du pilote Alpha sans d�caler le pointeur
  OR   AX,  AX          // Lev�e du Zero Flag
  JZ   @END             // Deux CODE END OF LINE = END OF IMG
  MOV  ESI, AdrSrc      // On recharge l'adresse de d�but de la ligne Source
  MOV  EDI, AdrDest     // On recharge l'adresse de d�but de la ligne Destination
  ADD  ESI, AdrSrInc    // On y rajoute le nb de bytes/ligne : ligne suivante
  ADD  EDI, AdrDtInc    // On y rajoute le nb de bytes/ligne : ligne suivante
  MOV  AdrSrc,  ESI     // Mise � Jour dans la pile
  MOV  AdrDest, EDI     // Mise � Jour dans la pile
  JMP  @DoItAgain       // C'est reparti

@End:
  MOV  ESI, &ESI        // Restauration des registres
  MOV  EDI, &EDI
  MOV  EBX, &EBX
  End;
End;



//############################################################
//###########     ALPHA BLIT DE DENSITE DEFINIE    ###########
//###########  S�bastien LEON CopyLeft GNU 5/1999  ###########
//############################################################

// Warning : On utilise le tas ! Ne pas placer en pile
var Dens1, Dens2  : LongInt;

procedure TDIBUltra.AlphaBlit(Dest : TDIBUltra; x, y, Dens : integer);

{$IFDEF NEVER_DEFINED}
  ######### ALPHA BLITTING ROUTINE : COMMON USAGE ##########
  ##                                                      ##
  ## Cette routine fonctionne de la mani�re suivante :    ##
  ## L'' appel se fait par exemple :                      ##
  ##           Src.AlphaBlit(Dest, x, y, Dens)            ##
  ##                                                      ##
  ## O� Src est DIBUltra                                  ##
  ## O� Dest est DIBUltra                                 ##
  ## O� x est la position de d�part en x du Blit          ##
  ## O� y est la position de d�part en y du Blit          ##
  ## (pour x et y = 0 on se place � la premi�re ligne et  ##
  ##  � la premi�re colonne de la destination.)           ##
  ## O� Dens est la densit� du blend appliqu� :           ##
  ##   Une densit� de 0 indique une transparence compl�te ##
  ##   de Src sur Dest.                                   ##
  ##   Une densit� de 32 indique une transparence nulle   ##
  ##   de Src sur Dest (Opacit� compl�te)                 ##
  ##                                                      ##
  ## Cette impl�mentation ne g�re pas encore le clipping  ##
  ## vrai : on veuillera donc � ce que Src ne d�passe pas ##
  ## Dest.                                                ##
  ##                                                      ##
  ##########################################################
{$ENDIF}
var
  BorneOK   : Boolean;
  // For ASM Implementation
  AdrDest   : Pointer; // Adresse du d�but de ligne de l'image destination
  AdrSrc    : Pointer; // Adresse du d�but de ligne de l'image source
  AdrDtInc  : LongInt; // Incr�ment pour passer d'une ligne n en n+1 (== Width_b) pour l'img Dest
  AdrSrInc  : LongInt; // Incr�ment pour passer d'une ligne n en n+1 (== Width_b) pour l'img Src
  NbLignes  : LongInt; // Nombre de lignes � traiter
  NbDWord   : LongInt; // Nombre de paires de pixels
  ESI, EDI  : LongInt; // Sauvegarde Registres
  EBX, ESP  : LongInt; // Sauvegarde Registres

Begin
  If (Dens<=00) Then Exit; // Transparence compl�te. Self est invisible
  If (Dens>=32) Then Begin Dest.Canvas.CopyRect(ClpRect,Cnv,ClpRect); Exit End; // Transparence nulle. Self est opaque sur Dest
  If (Self.PixelFormat<>DUpf16) Then Raise Exception.Create('La DIBUltra � afficher par filtre Alpha doit �tre une image � 16 Bpp !');
  If (Dest.PixelFormat<>DUpf16) Then Raise Exception.Create('L''image en Destination doit �tre une image � 16 Bpp !');
  // V�rification des bornes :
  BorneOK := (x>=0) AND (y>=0) AND ((x+DIBWidth) <= Dest.Width) AND ((y+DIBHeight) <= Dest.Height);
  If (Not BorneOK) Then Raise Exception.Create('Le clipping n''est pas encore support�.'#13'Dest doit contenir la DIB fournissant le blend.');
  // OK, Initialisation des Adresses
  AdrDest    := P(I(Dest.Scanline[y]) + 2*x);
  AdrSrc     := DIBAdr;
  AdrDtInc   := Dest.ByteWidth;
  AdrSrInc   := DIBWidth_b;
  NbDWord    := Abs(DIBWidth_b) div 4;
  NbLignes   := DIBHeight;
  Dens1      := Dens;
  Dens2      := 32-Dens;
  ASM
  MOV  &ESI, ESI         // Save Register
  MOV  &EDI, EDI
  MOV  &EBX, EBX
  MOV  &ESP, ESP         // NE PAS TRACER : On d�tourne le pointeur de pile !

  MOV  ESI,  AdrSrc      // Initialisation des pointeurs
  MOV  EDI,  AdrDest

@SUITELIGNE:

  MOV  ECX,  NbDWord // Compteur de pixels initialis�
  @SUITEPIXEL:
  // RAPPEL : Pixel au format 16Bpp : RRRRRVVV VVVBBBBB ; Masque  : $F800 $07E0 $001F
    MOV  EAX, [ESI]       // EAX = RGBRGB (Source)
    MOV  EBX, EAX         // On d�double
    AND  EAX, MaskVRB     // EAX = _V_R_B (Source)
    AND  EBX, Not MaskVRB // EBX = R_B_V_ (Source)
    SHR  EBX, 5           // EBX = _R_B_V (Source)
    IMUL EAX, Dens1       // * Dens2
    IMUL EBX, Dens1       // * Dens1
    MOV  EDX, [EDI]       // EDX = RGBRGB (Destin)
    MOV  ESP, EDX         // On d�double
    AND  EDX, MaskVRB     // EDX = _V_R_B (Destin)
    AND  ESP, Not MaskVRB // ESP = R_B_V_ (Destin)
    SHR  ESP, 5           // ESP = _R_B_V (Destin)
    IMUL EDX, Dens2       // * Dens2
    IMUL ESP, Dens2       // * Dens1
    ADD  EAX, EDX         // EAX = VxRxBx (Fusion)
    ADD  EBX, ESP         // EBX = RxVxBx (Fusion)
    SHR  EAX, 5           // EAX = _VxRxB (Fusion)
    AND  EBX, Not MaskVRB // EBX = R_V_B_ (Fusion)
    AND  EAX, MaskVRB     // EAX = _V_R_B (Fusion)
    OR   EAX, EBX         // EAX + EBX : Fusion termin�e
    MOV  [EDI], EAX

    ADD  ESI, 4      // D�placement des pointeurs
    ADD  EDI, 4

  LOOP @SUITEPIXEL

  // Fin de la boucle / Incr�mentation des pointeurs
  MOV  ESI, AdrSrc      // On recharge l'adresse de d�but de la ligne Source
  MOV  EDI, AdrDest     // On recharge l'adresse de d�but de la ligne Destination
  ADD  ESI, AdrSrInc    // On y rajoute le nb de bytes/ligne : ligne suivante
  ADD  EDI, AdrDtInc    // On y rajoute le nb de bytes/ligne : ligne suivante
  MOV  AdrSrc,  ESI     // Mise � Jour dans la pile
  MOV  AdrDest, EDI     // Mise � Jour dans la pile

  DEC  [NbLignes]       // A-t-on fini ?
  JNZ  @SUITELIGNE      // Non...

  @End:
  MOV  ESP, &ESP        // Restauration des registres
  MOV  ESI, &ESI
  MOV  EDI, &EDI
  MOV  EBX, &EBX
  End;
End;

procedure TDIBUltra.YFlipping;
var
  Line     : P;
  Src, Dst : P;
  Y        : I;
Begin
  If (DIBHeight<=1) Then Exit; // unuseful...
  GetMem( Line, Abs( DIBWidth_b ) );
  Try
  For Y := 0 To (DIBHeight div 2)-1 Do Begin
    Src := GetScanLine( Y );
    Dst := GetScanLine( DIBHeight-1-Y );
    Move ( Src^,  Line^, Abs( DIBWidth_b ) );
    Move ( Dst^,  Src^,  Abs( DIBWidth_b ) );
    Move ( Line^, Dst^,  Abs( DIBWidth_b ) );
  End;
  Finally
    FreeMem( Line );
  End;
End;

{
// By Richard
procedure TDIBUltra.KeyColorBlit(Dest : TDibUltra; Wipe : TDibUltra; Couleur : byte);
var
  AdrDest   : Pointer; // Adresse du d�but de ligne de l'image destination
  AdrSrc    : Pointer; // Adresse du d�but de ligne de l'image source
  AdrWipe   : Pointer; // Adresse du Wipe
  Taille    : Integer; // Taille des bitmaps
  EAX, EBX, EDX, EDI, ESI : LongInt; // To Save & Restore Registers

begin
  //� faire : test pour savoir si l'on a bien le m�me nbre de couleurs

//  If (Self.PixelFormat<>DUpf16) Then Raise Exception.Create('La DIBUltra � afficher par filtre Alpha doit �tre une image � 16 Bpp !');
//  If (Dest.PixelFormat<>DUpf16) Then Raise Exception.Create('L''image en Destination doit �tre une image � 16 Bpp !');
  If (Wipe.PixelFormat<>DUpf8) Then Raise Exception.Create('L''image guidant la transition doit �tre une image � 8 Bpp !');

  AdrDest    := Dest.DIBBits;
  AdrSrc     := DIBBits;
  AdrWipe    := Wipe.DIBBits; // Adresse du Wipe
  Taille     := DIBSize div 3 - 1;

  ASM
    MOV  &ESI, ESI
    MOV  &EDI, EDI
    MOV  &EAX, EAX
    MOV  &EBX, EBX
    MOV  &EDX, EDX

    MOV  ESI,  AdrSrc      // Initialisation des pointeurs
    MOV  EDI,  AdrDest
    MOV  EBX,  AdrWipe    // base de la ligne courante dans l'image du Masque
    MOV  ECX,  Taille


@TRAITEMENT:

    MOV  DL, [EBX]        // On lit la valeur dans le wipe
    CMP  DL, couleur      // Est-ce notre valeur � copier?
    JNZ   @INCREG         // Non, on passe � la valeur suivante

    MOV  EAX, [ESI]       // EAX = Rouge, Vert et Bleu (Source) ...et un octet inutile
    MOV  [EDI], EAX       // Oui, alors on recopie

@INCREG:
    ADD  EBX, 1       // INC EBX moins rapide?
    ADD  ESI, 3      // D�placement des pointeurs
    ADD  EDI, 3      //   LEA  EDI, EDI + 3 marche aussi

    DEC     ECX              //LOOP @SUITEPIXEL   //r�Z pourquoi?
    JNZ  @TRAITEMENT      // On n'a pas atteint la fin du bitmap, alors on continue...

@REGRESTORE:
        MOV  EBX, &EBX
        MOV  EAX, &EAX
        MOV  EDI, &EDI
        MOV  ESI, &ESI

    end; //de ASM
end;
}

