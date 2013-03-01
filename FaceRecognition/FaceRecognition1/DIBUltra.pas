//****************************************************************************//
//*****  UNITE DIBULTRA.PAS : ENCAPSULATION DES DIBs & AUTRES FONCTIONS  *****//
//****************************************************************************//
// Version 1.7   Copyright/CopyLeft GPL (C) 1999-2001 LEON Sébastien          //
//                                                                            //
// ## History : ##                                                            //
// Version 1.0 : (1/1999)                                                     //
// Version 1.1 : (4/1999) AlphaChanelBlit support 16 AlphaLevels              //
//               Fix a CreateFromFile Bug for 15, 16, 24 & 32 Bpp             //
// Version 1.2 : (5/1999) LZH for DUc ; AlphaChanelBlit support 33 AlphaLevels//
// Version 1.3 : (5/1999) AlphaBlit effect (support 33 AlphaLevels)           //
// Version 1.4 : (6/1999) Best support for 24 bpp UDC compressed DIBs         //
// Version 1.5 : (10/1999) remove StretchOn Bug, implement GetPixelIndex      //
// Version 1.6 : (03/2000) Allocate DownToTop DIBs instead of TopDown DIBs    //
//               (see below for the $DEFINE TOPDOWN to force TOPDOWN DIBS     //
// Version 1.7 : (10/2001) To compile with Delphi 6, I have fixed the syntax. //
//                                                                            //
// Contributors :                                                             //
// --------------                                                             //
//                                                                            //
//   Richard Devos  : Bench, Comments (mostly on udc format)                  //
//   Bob Danshfar   : Help to create and develop PenModes (AND, OR, XOR, NOT) //
//   Boris Daljevic : He show me an error in StechOn implementation           //
//   You ?                                                                    //
//                                                                            //
//----------------------------------------------------------------------------//
//                                                                            //
// Ce programme est libre, vous pouvez le redistribuer et/ou le modifier      //
// selon les termes de la LICENCE PUBLIQUE GENERALE GNU publiée par la        //
// Free Software Foundation version 2.                                        //
//                                                                            //
// This unit is distribued under the terms of the GPL. You can read the       //
// terms of this licence in the "GPL.html" file given with this unit.         //
//                                                                            //
// Ce programme est distribué car potentiellement utile, mais SANS AUCUNE     //
// GARANTIE, ni explicite ni implicite, y compris les garanties de            //
// commercialisation ou d'adaptation dans un but spécifique.                  //
// Reportez-vous à la Licence Publique Générale GNU pour plus de détails.     //
//                                                                            //
// Vous devez avoir reçu une copie de la Licence Publique Générale GNU        //
// en même temps que ce programme("gpl.html").                                //
// si ce n'est pas le cas, écrivez à la :                                     //
// Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA     //
// 02111-1307, États-Unis.                                                    //
//                                                                            //
//----------------------------------------------------------------------------//
//                                                                            //
// This program is free software; you can redistribute it and/or modify it    //
// under the terms of the GNU General Public License as published by the      //
// Free Software Foundation; either version 2 of the License, or (at your     //
// option) any later version. This program is distributed in the hope that    //
// it will be useful, but WITHOUT ANY WARRANTY; without even the implied      //
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the  //
// GNU General Public License for more details.                               //
//                                                                            //
// You should have received a copy of the GNU General Public License          //
// along with this program; if not, write to the Free Software Foundation,    //
// Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.            //
//                                                                            //
//                                                                            //
//****************************************************************************//
//                                                                            //
// DISCLAIMER OF WARRANTY :                                                   //
//                                                                            //
//   BECAUSE THE PROGRAM IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY     //
// FOR THE PROGRAM, TO THE EXTENT PERMITTED BY APPLICABLE LAW.  EXCEPT WHEN   //
// OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES     //
// PROVIDE THE PROGRAM "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED //
// OR IMPLIED, INCLDUING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF       //
// MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.  THE ENTIRE RISK AS  //
// TO THE QUALITY AND PERFORMANCE OF THE PROGRAM IS WITH YOU.  SHOULD THE     //
// PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING,   //
// REPAIR OR CORRECTION.                                                      //
//                                                                            //
//   IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING    //
// WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR        //
// REDISTRIBUTE THE PROGRAM AS PERMITTED ABOVE, BE LIABLE TO YOU FOR DAMAGES, //
// INCLDUING ANY GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING//
// OUT OF THE USE OR INABILITY TO USE THE PROGRAM (INCLDUING BUT NOT LIMITED  //
// TO LOSS OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY   //
// YOU OR THIRD PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE WITH ANY OTHER //
// PROGRAMS), EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE      //
// POSSIBILITY OF SUCH DAMAGES.                                               //
//                                                                            //
//****************************************************************************//

unit DIBUltra;

// Préférences de compilation ...
// Compilations options ...

{/$DEFINE TOPDOWN}            // Allocate TopDown Windows : Warning, Win32 doesn't manage corretly theses DIBs !

{/$DEFINE DEBUG}              // Rajoute des tests aux limites aux endroits sensibles : ne pas utiliser en version finale
                             // Add some tests in sensibles places : do not use in final release

{$DEFINE ASM_IMPLEMENTATION} // Compile les implémentations en assembleur plutôt que celles en pascal : meilleures performances
                             // Compile assembly implementations rather than pascal's : it's better, of course !

// Recommended configuration :
//   TOPDOWN undefined.
//   DEBUG undefined.
//   ASM_IMPLEMENTATION defined.
//
// Configuration recommandée : (pour une bonne vitesse de croisière)
//   TOPDOWN non défini.
//   DEBUG non défini.
//   ASM_IMPLEMENTATION défini.

                  //******************************************//
                  //            USING DIBULTRA :              //
                  //        UTILISATION DE DIBULTRA :         //
                  //******************************************//

// DIBULTRA IS A GRAPHICAL LIBRARY. IT PERFORMS LIKE SOME GDI* ROUTINES BUT MANY TIMES FASTER !
// DIBULTRA EST UNE LIBRAIRIE GRAPHIQUE. ELLE EMULE CERTAINES ROUTINES DU GDI* MAIS AGIT PLUS RAPIDEMENT

// * GDI : GRAPHICS DEVICE INTERFACE (WINDOWS HARD/SOFT WARE)

// You can use it with Delphi 2 3 4 the same manner
// Vous pouvez vous en servir avec Delphi 2 3 ou 4 de la même manière

// DIBULTRA is a full encapsulation of Windows DIBs
// DUBULTRA encapsule les DIBs Windows

// DIBULTRA Has his owne compressed DIB file format
// DIBUltre gère son propre format compressé de fichier pour ses images

// ***********************************************************//
// What can I do (faster) with DIBUltra ?                     //
// Que peut-on faire (rapidement) avec cette unité ?          //
//************************************************************//

// You can create 1, 4, 8, 15, 16, 24, 32 bit(s) per pixels DIBs
// On peut créer des DIBs à 1, 4, 8, 15, 16, 24, 32 bit(s) par pixels

// You can draw lines and plot points.
// On peut tracer des lignes et des points.

// Depend of your processor & graphical card, you can gain 200 to 1000 % of speed.
// En fonction de votre processeur et de votre carte graphique, vous pouvez gagner de 200 à 1000 % de vitesse

// This is version 1.5 : It is NOT REALLY optimized yet !
// Ce n'est que la version 1.5 : Elle n'est PAS ENCORE vraiment optimizée

// You can use and define Pen Styles like Dot, Dash ...
// These styles can be really useful because they are not initialised at every draw (like with the GDI) !
// You have a full control one these styles. (see below)
// On peut utiliser et définir différents styles de traits comme traits pointillés, tirets longs etc...
// Ces styles sont réellement utilisables car ils ne sont pas initialisés avant chaque tracé (comme le fait le GDI)
// On garde un contrôle total sur ces styles. (voir plus bas)

// You can draw and plot with colors or color indexes (for 1, 4, 8 bits DIBs)
// On peut dessiner indifferemment avec les couleurs ou les index de couleurs (pour des DIBs à 1, 4, 8 bpp)

// You can define a Clipping Region in the DIB. Nothing can be plotted or drawed elsewhere !
// On peut définir une région de clipping hors de laquelle rien ne pourra être tracé !

// You keep a full acces to Bits field for your manipulations
// On garde un accès direct aux bits de l'image pour des manipulations personnelles

// The method SaveToFile save the DIB in the compressed format (*.DUC : UltraDIB compressed)
// Much much better than PCX, better than GIF (5%)
// La méthode SaveToFile permet de sauver une image en format compressé (*.DUC : UltraDIB compressed)
// Bien bien meilleur que PCX, un peu meilleur que GIF (d'environ 5%)

// The methods CreateFromResourceName, CreateFromFile, CreateFromResourceID provide compressed DIB loading process ! (from ressouce & file)
// You can load a normal DIB too, but it is not really optimized.
// Les méthodes CreateFromResourceName, CreateFromFile, CreateFromResourceID permettent de charger des DIB compressés (d'une ressource ou d'un fichier)
// On peut charger une DIB normale (*.BMP) mais ce n'est pas optimisé

// A TCanvas object is provided with the DIBUltra for all others habituals modifications.
// Un objet TCanvas est fourni avec la DIBUltra pour permettre toutes les autres manipulations habituelles.

// The DIBUltra object is useful for buffering. Some methods are provided for this use.
// L'object DIBUltra est utile comme buffer ; des méthodes facilitent cette uti:isation.

// You can freely read the source, the ASM source is heavily commented too !
// Le source est librement consultable et largement commenté (même celui en assembleur)

// Methods & Properties :
// Méthodes et propiétés :

{$IFDEF NEVER_DEFINED}

// METHODS / METHODES
// constructors :
  CreateFromResourceName(Instance : THandle ; const ResName: string);
    // Constructor similar to TBitmap.LoadFromResourceName()
    // Constructeur similaire à TBitmap.LoadFromResourceName()

  CreateFromResourceID  (Instance : THandle ; ResID: Integer);
    // Constructor similar to TBitmap.LoadFromResourceID()
    // Constructeur similaire à TBitmap.LoadFromResourceID()

// Mode d'emploi pour utiliser les DIB compressées comme ressources :
// A lire en englais :

//************************************
//** How to use a UltraDIB resource **
//************************************
//
// 1 . Build a compressed UltraDIB File
//
//   DIB.CreateFromFile("FileName.bmp")
//   //save it to a file.DUc
//   DIB.SaveToFile("FileName.DUc")
//
//
// 2 . Make a script : toto.rc
//
//     FILE toto.rc
//     ************************************
//     * // COMMENTS                      *
//     * // Name  Type  File              *
//     * image1 RCDATA "FileName.udc"     *
//     ************************************
//
//
// 3 . Script Compilation
//
//   In DOS, enter the command :
//
//   Brcc32 -v toto.rc
//
//   => toto.RES will be generate !
//
//
// 4 . Add the ressource to the exe
//
//   SomeWhere in your file.pas, enter the Compilation Command
//
//   {$R TOTO.RES} // Add this resource to your exe
//
//   You can write it after {$R *.DFM} for example
//
//
// 5 . Create a UltraDIB from this ressource
//
//   When needed, you can create a DUBUltra from ressource :
//
//   var DIB : TDIBUltra;
//   Begin ...
//   DIB := TDIBUltra.CreateFromResourceName(HInstance, 'image1');
//   ...
//
// Warning : The Compression process is not yet optimized
// (just PASCAL implementation) and can be slow for huge DIB
//
// The Decompression Process is optimized. Next version will support
// DIB animation from memory compressed DIBs !
//

  CreateFromStream      (Stream: TStream);
    // Constructor similar to TBitmap.LoadFromStream()
    // Constructeur similaire à TBitmap.LoadFromStream()

  CreateFromFile        (const Filename: string);
    // Constructor similar to TBitmap.LoadFromFile()
    // Constructeur similaire à TBitmap.LoadFromFile()

  Create (Width, Height : Word ; PF : TDUPixelFormat ; pLogPalette : Pointer );
    // For pLogPalette, if you don't have a idea (or the resolution is higher than 8 bpp)
    // you can use NilPalette, or nil
    // Pour l'argument pLogPalette, si vous n'avez pas idée de ce que l'on peut passer ou si
    // votre image à une résolution suppérieure à 256 couleurs, passer NilPalette ou Nil

// Procedures :
  BufferToUpdate;
    // When the DIB buffer is unsynchonize with your application, call this method
    // Next call to BufferOf will return false
    // Quand le DIBUltra buffer n'est plus synchronisé avec l'application, appelez cette méthode
    // Le prochain appel à BufferOf rendra faux

  BufferDim (Width, Height : Word);
    // Test if the buffer has the same dimensions than the parameters
    // YES : everything is OK, Nothing happens
    // NO  : Next call to BufferOf will return false AND :
    //       IF (Width <= DIB.Width) AND (Height <= DIB.Height) Then Nothing happens (the buffer is not redimensionned)
    //       ELSE the buffer is enlarged to the new larger dimension(s)
    // Teste si le buffer a les mêmes dimensions que les paramètres
    // Si OUI : tout est bon, rien ne se passe
    // SINON  : Le prochain appel à BufferOf rendra faux
    //          Si (Width <= DIB.Width) AND (Height <= DIB.Height) Alors rien ne se passe {le buffer n'est pas redimensionné plus petit}
    //          Sinon le buffer est élargi sur sa (ses) dimension trop courte

// Fonction :
  BufferOf  (AOwner : TObject) : Boolean;
    // Associate the buffer with some graphical objects (like TPaintBox)
    // If the last call to BufferOf(ObjectX) was from ObjectX then it returns True
    // (It returns False if the buffer has been redimensionned or is not synchonized)
    // If (BufferOf(X)=True) Then It must contains the same last picture !

// These 3 Buffers methods can be used in this way :
// Ces 3 méthodes de buffering peuvent être utilisées typiquement de cette façon :

  procedure TForm.FormCreate(Sender : TObject);
  Begin // Buffer allocation
    DIB := TUltraDIB.Create(1,1,UDpf16,NilPalette);
  End;

  procedure TForm.FormClose(Sender: TObject; var Action: TCloseAction);
  Begin // Buffer Freeing / Libération du Buffer
    DIB.Free;
  End;

  procedure TForm.PaintBox1Paint(Sender: TObject);
  Begin
    // Test dimensions
    DIB.BufferDim(PaintBox1.Width, PaintBox1.Height);
    // Test last user / Test du dernier utilisateur
    If Not DIB.BufferOf(PaintBox1) Then
    Begin
      // Draw on buffer only if it is useful
      DrawingProcedure1(DIB); // etc...
    End;
    // BitBlit on PaintBox1.Canvas with the DIBUltra.DrawnOn method / La méthode DIBUltra.DrawnOn facilite les choses
    With PaintBox1 Do DIB.DrawOn(Rect(0,0,Width,Height),Canvas);
  End; // DIBUltra is not a TPicture

  procedure TForm.PaintBox2Paint(Sender: TObject);
  Begin
    // Test dimensions
    DIB.BufferDim(PaintBox2.Width, PaintBox2.Height);
    // Test last user
    If Not DIB.BufferOf(PaintBox2) Then
    Begin
      // Draw on buffer only if it is useful
      DrawingProcedure2(DIB); // etc...
    End;
    // BitBlit on PaintBox1.Canvas with the DIBUltra.DrawnOn method / La méthode DIBUltra.DrawnOn facilite les choses
    With PaintBox2 Do DIB.DrawOn(Rect(0,0,Width,Height),Canvas);
  End;

// Procedure :
  ClearAll;
    // Fill All the DIB with the Brush Color
    // Remplit toutes la DIB par la couleur du pinceau

  ClearClipRect;
    // Fill all the ClipRect with the Brush Color
    // Remplit tout le rectangle de clipping par la couleur du pinceau

  PrepareStyle;
    // Rol the style until the first point of the style is visible
    // "Rotate" le masque jusqu'à présenter un point visible lors du prochain tracé

  RotateStyle(n : Byte);
    // Rol the style (n MOD 32) times
    // Effectue une rotation du masque, (n MODULO 32) fois

  // You can use the style in this way :
  // Vous pouvez utiliser les styles de la manière suivante :

    DIB.PenStyle := DUpsDoubleDash; // Motif = <******    **    ******    **    >
    // If you RotateStyle(5) then : Motif = <*    **    ******    **    *****>
    // Si vous appelez RotateStyle(5) alors le motif sera <*    **    ******    **    *****>
    DIB.RotateStyle(5);
    // Now, you trace a line of 7 pixels :
    // Maintenant, vous tracez une line de 7 pixels :
    DIB.StepTo(5,0);
    // It will draw only  "1000011" ( with 0=tranparent ; 1=PenColor)
    // Cela tracera "1000011" ( with 0=tranparent ; 1=PenColor)
    // PenStyle = <    ******    **    ******    **>
    DIB.PrepareStyle;
    // Now, PrepareStyle will turn the pen style 4 times :
    // Maintenant, l'appel à PrepareStyle tournera le stylo 4 fois :
    // PenStyle = <******    **    ******    **    >

  // BE CAREFUL, THE PEN STYLE IS USED FOR PENWIDTH OF 1, 2, 3 Pixels
  // For larger PenWidth, the GDI routine is used

   SaveToFile  (const Filename: string ; SavingMode : TSaveMode ; FinalBpp : TDUPixelFormat); // Sauve sur disque la DIB
   SaveToStream(AStream : TStream ; SavingMode : TSaveMode ; FinalBpp : TDUPixelFormat); // Sauve dans un stream la DIB
    // Save on disk (or in a stream) the DIB.
    // With SavingMode, you can choose the output format :  Windows (not yet implemented) ou UDC
    // For maximum compression, set true the LZHFormat property
    // Enregistre sur disque (ou dans un flux) la DIB en mémoire.
    // SavingMode spécifie le mode : Windows (non implémenté) ou UDC
    // Pour bénéficier du maximum de compression, utiliser l'option par défaut LZHFormat := OK

  FillRect (R : TRect);
    // Like TBitmap.Canvas.FillRect but just in ClipRect
    // Comme Canvas.FillRect mais dans le ClipRect

  SetPalette (pLogPalette : Pointer);
    // Affect a new palette to the DIB
    // Affecte une nouvelle palette à la DIB

  MoveTo     (x1,y1 : Integer);
    // Like TBitmap.Canvas.MoveTo
    // If you use the const NoChange for x AND/OR y, the x AND/OR y position will not be modified
    // Comme TBitmap.Canvas.MoveTo
    // Si vous utilisez la constante NoChange pour x ET/OU y, le stylo ne se déplacera pas de x ET/OU y

  LineTo     (x2,y2 : Integer);
    // Like TBitmap.Canvas.LineTo (Faster)
    // If you want to trace like Windows, set GDILike := True
    // If you use the const NoChange for x AND/OR y, the x AND/OR y position will not be modified
    // Actually, LineTo is not implemented for 1 & 4 Bpp (But plot() is)
    // Comme Canvas.LineTo avec le style, le ClipRect et la vitesse en +
    // Si vous désirez tracer comme Windows, Positionnez GFILike à Vrai
    // Si vous utilisez la constante NoChange pour x ET/OU y, le stylo ne se déplacera pas de x ET/OU y
    // Actuellement, LineTo n'est pas implémenté pour les résolutions de 1 et 4 Bpp (mais plot l'est)

  StepTo     (dx,dy : Integer);
    // Trace a relative line (from pen position = last point drawed)
    // Tire une ligne relative à la position actuelle du stylo de dx et dy

  Plot       (Nx,Ny : Integer); // Trace un point avec le PenColor courant
    // Like TBitmap.Canvas.Pixel[x,y] := TBitmap.Canvas.Pen.Color (Faster)
    // If you use the const NoChange for x AND/OR y, the x AND/OR y position will not be modified
    // Comme TBitmap.Canvas.Pixel[x,y] := TBitmap.Canvas.Pen.Color (+ rapide)
    // Si vous utilisez la constante NoChange pour x ET/OU y, le stylo ne se déplacera pas de x ET/OU y

  DirectPlot (x,y : Integer; ColIdx : TColor );
    // Plot a point exactly where you want ! If it is out of the DIB, Windows Crashs !!!
    // Use VERY CAREFULLY (OR DON'T USE IT IF YOU ARE NOT SURE)
    // The Const NoChange doesn't work / the pen is not deplaced
    // Place un point exactement là où l'on veut. Si c'est en dehors de la DIB, Windows se plante !!!
    // A utiliser TRES PRECAUTIONNEUSEMENT (OU PAS DU TOUT SI VOUS N'ETES PAS SUR)
    // L'utilisation de la constante n'est pas possible / la position du stylo n'est pas modifiée

  DirectLineTo (Sg : TLine);
    // NOT YET IMPLEMENTED : Futur Specifications :
    // Do NOT CLIP the Segment to trace.  If JUST ONE point is out of the DIB, Windows Crashs !!!
    // Use VERY CAREFULLY (OR DON'T USE IT IF YOU ARE NOT SURE)
    // PAS ENCORE IMPLEMENTE : Spécifications Futures :
    // N'effectue PAS DE VERIFICATION DES LIMITES DU SEGMENT. Si un des points est en dehors de la DIB : Windows plante !!!
    // A utiliser TRES PRECAUTIONNEUSEMENT (OU PAS DU TOUT SI VOUS N'ETES PAS SUR)

  AlphaChanelBlit (Dest : TDIBUltra; x, y, Num  : integer);
    // This special effect (written in assembly language => quick) blend the DIB on Dest DIB
    // using his Alpha Chanel Mask.
    // Cet effet spécial (écrit en asm => rapide) pose l'image courante sur Dest en utilisant
    // le masque Alpha
  AlphaBlit       (Dest : TDIBUltra; x, y, Dens : integer);
    // This special effect (written in assembly language => quick) blend the DIB on Dest DIB
    // using the Dens (Density) value as Alpha Chanel.
    // Cet effet spécial (écrit en asm => rapide) pose l'image courante sur Dest en utilisant
    // la valeur de densité Dens comme masque Alpha.


// Properties / Propriétés :

  Pixels     [X,Y: Integer]: TColor      -- Like TBitmap.Pixels[]
                                         -- Comme TBitmap.Pixels[]

  PixelsIndex[X,Y: Integer]: TColorIndex -- Like TBitmap.Pixels[] but Get or Set the Indexed Color !
                                         -- Comme TBitmap.Pixels[] but prend et rend une couleur indexée !

  BrushColor               : TColor      -- Like TBitmap.Canvas.Brush.Color
                                         -- Comme TBitmap.Canvas.Brush.Color

  BrushColorIndex          : TColorIndex -- The Value is understand like an Color Index
                                         -- Cette valeur est comprise comme un numéro d''index de couleur

  PenColor                 : TColor      -- Like TBitmap.Canvas.Pen.Color
                                         -- Comme TBitmap.Canvas.Pen.Color

  PenColorIndex            : TColorIndex -- The Value is understand like an Color Index
                                         -- Cette valeur est comprise comme un numéro d''index de couleur

  PenWidth                 : LongInt     -- Like TBitmap.Canvas.Pen.Width
                                         -- Comme TBitmap.Canvas.Pen.Width

  PenStyle                 : LongInt     -- Near TBitmap.Canvas.Pen.Style
                                         -- Proche de TBitmap.Canvas.Pen.Style

  ClipRect                 : TRect       -- Like TBitmap.ClipRect BUT READ & WRITE property
                                         -- Comme TBitmap.ClipRect mais en LECTURE & ECRITURE

  GDIStyle                 : Boolean     -- False : Draw all the line ; True : Draw all the line save the last point (like GDI)
                                         -- Faux : Trace toute la ligne ; Vrai : Trace toute la ligne sauf le dernier point (like GDI)

  PixelFormat              : TDUPF       -- Like TBitmap.PixelFormat (Delphi 3 & higher)
                                         -- Comme TBitmap.PixelFormat (Delphi 3 & plus)

  Canvas                   : TCanvas     -- Really like TBitmap.Canvas
                                         -- Vraiment comme TBitmap.Canvas

  Width                    : Integer     -- Like TBitmap.Width
                                         -- Comme TBitmap.Width

  Height                   : Integer     -- Like TBitmap.Height
                                         -- Comme TBitmap.Height

  Size                     : Integer     -- The Size of the bits field (in byte)
                                         -- Nombre d''octets de l''image

  Bits                     : Pointer     -- pointer on the bits field
                                         -- pointeur sur les bits de l''image

  ScanLine[R:Integer]      :Pointer      -- pointer on the bits Line field
                                         -- pointeur sur les bits de la ligne R

  Header                   : Pointer     -- pointer on the DIB Header (Cf Win32 API)
                                         -- pointeur sur le DIB Header (Cf Win32 API)

  Handle                   : THandle     -- Like TBitmap.Handle (Delphi 3 & higher)
                                         -- Comme TBitmap.Handle (Delphi 3 & plus)

  Hpalette                 : hPalette    -- Like TBitmap.Hpalette BUT READONLY property
                                         -- Comme TBitmap.Hpalette MAIS EN LECTURE SEULE

  Bpp                      : Integer     -- Give the Bits per pixels (for 15Bit & 16Bits : Bpp = 16)
                                         -- Donne la résolution (pour 15 Bpp & 16 Bpp : Bpp = 16)

  ByteWidth                : Integer     -- Give the Byte size of a line
                                         -- Donne la taille en octets d''une ligne

  PenMode                  : TDUPenMode  -- Near WinAPI SetRop2() modes or TCanvas.PenMode
{$ENDIF}

// I'm sorry, but next comments are french (This is my natural langage (a nice one))
// Have some fun with ASM source !
// Of course, I encourage you in adding comments and improving code...

////////////////////////////////////////////////////////////////////
//                                                                //
//  Attention, les implémentations pascal de cette unité          //
//  présentent deux particularités :                              //
//                                                                //
//  * elles ne sont pas optimisées pour le compilateur pascal     //
//  mais "collent" aux implémentations assembleur pour faire      //
//  plus facilement un parallèle entre les deux (lorsque cela     //
//  est possible)                                                 //
//                                                                //
//  * elles sont là dans le cas d'un portage vers une plateforme  //
//  non CISC 80x86 et facilitent une recompilation temporaire     //
//  peu optimisé. Dans ce cas, il faut aussi regarder du coté     //
//  des accès memoire Little/Big Endian ...                       //
//                                                                //
////////////////////////////////////////////////////////////////////

interface

uses
  Windows, Sysutils, Graphics, Classes, Dialogs,
  DIBType,  // Contient les Types de TDIBUltra
  DIBCodec; // Contient les Codec de TDIBUltra : vous pouvez vous en servir (LZH)

Type
  // ////////////  ##  DON'T USE THESE TYPES  ##  \\\\\\\\\\\\
  // \\\\\\\\\\\\ USE RATHER DIBType.pas For That ////////////

  // Type plutôt à usage interne
  TDUPF = TDUPixelFormat; // Pour raccourcir un peu
  // ******** LIGNE PRETE A ETRE TRACEE **********
  TLine = record
    x1, y1, x2, y2 : Integer;
    dx, dy         : Integer;
  end;
  // ********* TBITMAPINFO Personnalisé ***********
  TDIBUltraInfo  =  Packed Record
    Header : TBITMAPINFOHEADER;
    Case Boolean Of
      True : (Indices : array [0..255] of Word);
      False: (RedMask, GreenMask, BlueMask : LongInt);
  End;

  TDIBUltra = Class
  private
    X,Y          : Integer;
    ClpRect      : TRect;
    Cnv          : TCanvas;
    CnvOK        : Boolean;
    Client       : TObject;
    Alpha        : TAlpha;
    DIBheader    : TDIBUltraInfo;
    PDIBheader   : Pointer;
    DIBbits      : Pointer;
    DIBAdr       : Pointer;
    DIBhandle    : THandle;
    DIBDC        : HDC;
    DIBTransp    : Byte;
    DIBStatus    : TDIBType;
    DIBWidth     : integer;
    DIBHeight    : integer;
    DIBWidth_b   : integer; // Real Width (in bytes) of a DIB line (ever DWORD aligned)
    DIBHalfWidth : integer; // => DIBWidth_b div 2
    DIBSize      : integer;
    DIBBPP       : integer;
    DIBResol     : TDUPixelFormat;
    DIBhpalette  : hPalette;
    DIBLogPal    : T256ColorsPalette;
    WidthPen     : LongInt;
    ColorPen     : TColor;
    ColorBrh     : TColor;
    Mask         : LongInt;
    Mode         : TDUPenMode;
    PcoulL       : LongInt; // Pen LongInt Color
    PcoulW       : word;    // Pen Word Color Index
    PcoulR       : byte;    // Pen Byte Color Index
    PcoulV       : byte;    // Pen Byte Color Index
    PcoulB       : byte;    // Pen Byte Color Index
    BcoulL       : LongInt; // Brush LongInt Color
    BcoulW       : word;    // Brush Word Color Index
    BcoulR       : byte;    // Brush Byte Color Index
    BcoulV       : byte;    // Brush Byte Color Index
    BcoulB       : byte;    // Brush Byte Color Index
    ExitClip     : Boolean; // Cause d'un non tracé : Rectangle de clipping
    ExitMask     : Boolean; // Cause d'un non tracé : Masque du stylo = Clear
    ExitMode     : Boolean; // Cause d'un non tracé : Mode du stylo = DUpmNOP
    ExitWidth    : Boolean; // Cause d'un non tracé : Largeur du stylo de 0
    CantDraw     : Boolean; // ExitClip OR ExitMask OR ExitWidth OR ExitMode
    NotLast      : Boolean; // Dépend de l'émulation GDI
  protected
    procedure   DIBFromStream    (AStream : TStream);
    Procedure   BuildDIB         (AStream: TStream);
    Procedure   CreateDIB        (Width, Height : Word ; PF : TDUPixelFormat ; pLogPalette : Pointer );
    procedure   OptimizeDIB;
    procedure   WLZH             (Val : Boolean);
    Function    RLZH : Boolean;

    // Routines de gestion des points
    Function    GetPixel      (Nx, Ny : Integer)      : TColor;
    procedure   SetPixel      (Nx, Ny : Integer; Coul : TColor);
    Function    GetPixelIndex (Nx, Ny : Integer)      : TColorIndex;
    procedure   SetPixelIndex (Nx, Ny : Integer; Idx  : TColorIndex);
    // fin des routines de gestion des points

    // Routines de gestion du pinceau et du stylo
    procedure   SetPenColors       (Idx  : LongInt    );
    procedure   SetBrushColors     (Idx  : LongInt    );
    procedure   SetBrushColorIndex (Idx  : TColorIndex);
    Function    GetBrushColorIndex       : TColorIndex ;
    procedure   SetPenColorIndex   (Idx  : TColorIndex);
    Function    GetPenColorIndex         : TColorIndex ;
    procedure   SetBrhColor        (coul : TColor     );
    procedure   SetPenColor        (coul : TColor     );
    // fin des routines de gestion du pinceau et du stylo

    // Could be public to generate const pal (but rather for internal use)
    Function    GetColorFromIndex  (Idx  : LongInt    ): TColor;
    Function    GetIndexFromColor  (Coul : LongInt    ): TColorIndex;

    procedure   SetClipRect (R : TRect);
    procedure   SetWidthPen (PWdth : LongInt);
    procedure   SetMask     (M     : LongInt);
    procedure   SetMode     (M     : TDUPenMode);
    function    PlotON                    : Boolean;
    function    GetScanLine (R : Integer) : Pointer;
    procedure   Line;

  public
    // Créateurs & Destructeurs
    constructor CreateFromStream      (AStream  : TStream);
    constructor CreateFromResourceName(Instance : THandle ; const ResName: string);
    constructor CreateFromResourceID  (Instance : THandle ; ResID: Integer);
    constructor CreateFromFile        (const Filename: string);
    constructor Create (Width, Height : Word ; PF : TDUPixelFormat ; pLogPalette : Pointer );
    destructor  Destroy;  override;
    // Routines de Bufferisation
    procedure   BufferToUpdate;
    procedure   BufferDim   (Width, Height : Word);
    Function    BufferOf    (AOwner : TObject) : Boolean;
    // Routines d'effets spéciaux
    procedure   AlphaChanelBlit (Dest : TDIBUltra; x, y, Num  : integer);
    procedure   AlphaBlit       (Dest : TDIBUltra; x, y, Dens : integer);
    Procedure   YFlipping;

    procedure   SetAlphaFile( Const MaskFile : String ; Num , Delay : Integer);
    procedure   SetAlphaMask( Mask : TDIBUltra        ; Num , Delay : Integer);
    procedure   NoAlpha;
    procedure   MakeTransparent(ColorIndex : Byte);
    procedure   MakeOpaque;

    procedure   DrawOn      (Dest : TRect ; Canevas : TCanvas ; Xsrc, Ysrc : Integer );
    procedure   TiledOn     (Const Dest : TRect; Canevas : TCanvas);
    procedure   StretchOn   (Dest : TRect ; Canevas : TCanvas);
    procedure   ClearAll;                      // Rempli toute la DIB de la couleur du Brush
    procedure   ClearClipRect;                 // Rempli le ClipRect de la couleur du Brush
    procedure   PrepareStyle;                  // "Rotate" le masque jusqu'à présenter un point visible
    procedure   RotateStyle (n : Byte);        // Effectue une rotation du masque, n fois
    procedure   FillRect    (R : TRect);       // Comme Canvas.FillREct mais dans le ClipRect
    procedure   MoveTo      (x1,y1 : Integer); // Déplace le stylo graphique
    procedure   LineTo      (x2,y2 : Integer); // Comme Canvas.LineTo avec le style, le ClipRect et la vitesse en +
    procedure   StepTo      (dx,dy : Integer); // Trace une ligne relativement de dx et dy
    procedure   Plot        (Nx,Ny : Integer); // Trace un point avec le PenColor courant
    procedure   SetPalette  (pLogPalette : Pointer);
    Function    StdIndex    (Cl    : TDUColor) : TColorIndex;
    Function    PenPos      : TPoint; // Thanks to Bob Danshfar : I forget that !
    Function    ReleaseHandle: THandle;
    procedure   SaveToFile  (const Filename: string ; SavingMode : TSaveMode ; FinalBpp : TDUPixelFormat); // Sauve sur disque la DIB
    procedure   SaveToStream(AStream : TStream ; SavingMode : TSaveMode ; FinalBpp : TDUPixelFormat); // Sauve dans un stream la DIB

    procedure   DirectPlot  (Nx, Ny : Integer; ColIdx : TColor ); // Place un point sans rien vérifier : Aie !
    procedure   DirectLineTo(Sg     : TLine); // Trace une ligne sans rien vérifier : Aie !

    property    Pixels     [X,Y: Integer]: TColor      read GetPixel      write SetPixel;      // Cf Plot
    property    PixelsIndex[X,Y: Integer]: TColorIndex read GetPixelIndex write SetPixelIndex; // Cf Plot

    property    BrushColor      : TColor      read ColorBrh           Write SetBrhColor        default ClBlack  ; // Concerne la couleur du fond
    property    PenColor        : TColor      read ColorPen           Write SetPenColor        default ClWhite  ; // Concerne la couleur du stylo
    property    BrushColorIndex : TColorIndex read GetBrushColorIndex Write SetBrushColorIndex default 0 ; // Concerne la couleur du fond
    property    PenColorIndex   : TColorIndex read GetPenColorIndex   Write SetPenColorIndex  ; // Concerne la couleur du stylo

    property    PenWidth   : LongInt   read WidthPen Write SetWidthPen default 1        ; // Concerne la couleur du stylo
    property    PenStyle   : LongInt   read Mask     Write SetMask     default DUpsSolid; // Concerne le style du trait
    property    PenMode    : TDUPenMode read Mode    Write SetMode     default DUpmCOPY ;
    property    ClipRect   : TRect     read ClpRect  Write SetClipRect                  ; // Concerne la zone de clipping
    property    GDIStyle   : Boolean   read NotLast  Write NotLast     default False    ; // Trace toute la ligne sauf le dernier point comme la GDI ?
    property    LZHFormat  : Boolean   read RLZH     Write WLZH;
    property    ScanLine[R:Integer]:Pointer read GetScanLine; // ScanLine lit les pixels ligne par ligne
    property    Bits       : Pointer   read DIBBits;
    property    PixelFormat: TDUPF     read DIBResol;
    property    Canvas     : TCanvas   read Cnv;
    property    Width      : Integer   read DIBWidth;
    property    Height     : Integer   read DIBHeight;
    property    Size       : Integer   read DIBSize;
    property    Status     : TDIBType  read DIBStatus;
    property    Header     : Pointer   read PDIBheader;
    property    Handle     : THandle   read DIBHandle;
    property    Hpalette   : hPalette  read DIBHPalette;
    property    Bpp        : Integer   read DIBBpp;
    property    ByteWidth  : Integer   read DIBWidth_b;
  end;

Implementation

Uses Forms;

Type
  I         = Integer;                 // type utile aux transtypage
  P         = Pointer;
  PxlW      = array [0..0] of Word;    // Sert à Trantyper le pointer DIBBits
  PxlB      = array [0..2] of byte;
  PxlL      = array [0..0] of LongInt;
  DIB_ERROR = class(Exception);        // type hélas quelquefois utile aussi

Const BufSiz = 1152; // Must be >= SizeOf(MultiTypeHeader.2) ie >= (1024+4+40+14)=1082

Type
  MultiTypeHeader = Packed Record // Un type polymorphe pour les différents formats
    Case integer of
      0 : (Bytes    : array[0..(BufSiz-1)] of Byte;);
      1 : (UltraDIB : TCompressedDIBFileHeader);
      2 : (HDIBFile : TBITMAPFILEHEADER ; HDIBInfoHeader : TBITMAPINFOHEADER ; RGB : RGBArray );
    End;  {Size : 14 + 40 + 1024 = 1078 octets }

const
  // Constantes en rapport avec la sauvegarde et le chargement des DIB
  fBM        = $4D42; // Identifiant d'une Bitmap habituelle
  fUltraDIB  = $4DFE; // Identifiant d'une UltraDIB compressée
  fAlphaInfo = $A6;   // Identifiant d'une structure Alpha
  fSTDPal    = $80;   // Masque indiquant une palette système

  // Les constantes qu'il est préférable de ne pas avoir à lire ...
  DIBErr1   = 'DIB ERROR :'#13'Can NOT create DIB ? ? !'
                          +#13'Impossible de créer une image tampon ? ? !';
  DIBErr2   = 'DIB ERROR :'#13'Internal error during segment clipping !'
                          +#13'Erreur d''encadrement du segment !';
  DIBErr3   = 'DIB ERROR :'#13'Error during loading process !'
                          +#13'Erreur lors du processus de chargement !';
  DIBErr4   = 'DIB ERROR :'#13'Unrecognized Bitmap format !'
                          +#13'Format graphique NON reconnu !';
  DIBErr5   = 'DIB ERROR :'#13'Can''t read stream or file.'
                          +#13'Problème de lecture de fichier ou de flux.';

// Petite fonction utilitaire
Procedure GetValidPalette (PF : TDUPixelFormat ; var pLogPalette : Pointer);
Begin
  If ((pLogPalette = NilPalette) OR (PF>DUpf8)) Then
  Case PF Of
    DUpf1 : pLogPalette := @PaletteSystem1Bits;
    DUpf4 : pLogPalette := @PaletteSystem4Bits;
    DUpf8 : pLogPalette := @PaletteSystem8Bits;
    Else    pLogPalette := nil; // No palettes for high resolutions
  End;
End;

{$RANGECHECKS OFF}
{ ---------------------------------------------------------------- }
{                             DIB object                           }
{ ---------------------------------------------------------------- }

Const BPPxls   : array[DUpf1..DUpf32] of Byte    = (1,4,8,16,16,24,32);
      LastCoul : array[DUpf1..DUpf32] of LongInt = (1,15,255,32767,65535,16777215,16777215);

//******************** FLOPPE DE CONSTRUCTEURS *****************
//
constructor TDIBUltra.CreateFromResourceName(Instance : THandle ; const ResName: string);
begin
  inherited Create;
  DIBFromStream(TResourceStream.Create(Instance, ResName, RT_RCDATA));
end;

constructor TDIBUltra.CreateFromResourceID(Instance : THandle ; ResID: Integer);
begin
  inherited Create;
  DIBFromStream(TResourceStream.CreateFromID(Instance, ResID, RT_RCDATA));
end;

constructor TDIBUltra.CreateFromStream(AStream : TStream);
begin
  inherited Create;
  DIBFromStream(AStream);
end;

constructor TDIBUltra.CreateFromFile(const Filename: string);
begin
  inherited Create;
  DIBFromStream(TFileStream.Create(Filename, fmOpenRead));
end;

constructor TDIBUltra.Create ( Width, Height : Word ; PF : TDUPixelFormat ; pLogPalette : Pointer );
begin
  inherited Create;
  GetValidPalette(PF, pLogPalette);
  If (pLogPalette<>nil) Then DIBLogPal := T256ColorsPalette(pLogPalette^);
  DIBStatus   := [DUtLZH];
  CnvOK       := False;
  Cnv         := TCanvas.Create;
  Client      := nil;
  Alpha       := nil;
  X           := 0;
  Y           := 0;
  WidthPen    := 1;
  DIBhandle   := 0;
  DIBhpalette := 0;
  ExitClip    := False;
  ExitMask    := False;
  ExitWidth   := False;
  CantDraw    := False;
  NotLast     := False;
  Mode        := DUpmCOPY;
  Mask        := DUpsSolid;
  PDIBheader  := @DIBheader;
  CreateDIB(Width, Height, PF, @DIBLogPal); // Création de la DIB
  ClpRect     := Rect(0,0,(Width-1),(Height-1));
  SetPenColor (ClBlack);
  SetBrhColor (ClWhite);
end;

//******************* FIN DES CONSTRUCTEURS ************************

//************************ DESTRUCTEUR *****************************

destructor TDIBUltra.Destroy;
begin
  Cnv.Free; CnvOK := False;
  if (Alpha    <>nil) then FreeMem(Alpha);
  {if (DIBhandle  <>0) then}
  DeleteObject (DIBhandle);
  {If (DIBhpalette<>0) then}
  DeleteObject (DIBhpalette);
  DeleteDC(DIBDC);
  inherited;
end;

//********************* FIN DU DESTRUCTEUR *************************

procedure TDIBUltra.DIBFromStream(AStream : TStream);
begin
  DIBStatus   := [DUtLZH];
  CnvOK       := False;
  Cnv         := TCanvas.Create;
  Client      := nil;
  X           := 0;
  Y           := 0;
  WidthPen    := 1;
  DIBhandle   := 0;
  DIBhpalette := 0;
  ExitClip    := False;
  ExitMask    := False;
  ExitWidth   := False;
  CantDraw    := False;
  NotLast     := False;
  Mask        := DUpsSolid;
  PDIBheader  := @DIBheader;
  BuildDIB    (AStream); // Libération du stream dans BuildDIB
  SetPenColor (ClBlack);
  SetBrhColor (ClWhite);
  ClpRect     := Rect(0,0,(Width-1),(Height-1));
end;

Procedure TDIBUltra.CreateDIB (Width, Height : Word ; PF : TDUPixelFormat ; pLogPalette : Pointer );
var E : Integer;
Begin
  DIBBPP       := BPPxls[PF];
  DIBWidth     := Width;
  DIBHeight    := Height;
  DIBWidth_b   := ((DIBWidth * DIBBPP + 31) AND -32 ) shr 3;
  DIBHalfWidth := DIBWidth_b div 2;
  DIBSize      := DIBWidth_b*DIBHeight;
  DIBbits      := nil;
  DIBDC        := CreateCompatibleDC(0);
  DIBResol     := PF;
{$IFNDEF TOPDOWN}
  DIBWidth_b   := - DIBWidth_b;
  DIBHalfWidth := - DIBHalfWidth;
{$ENDIF}
  with DIBheader, Header do
  begin
    biSize          := sizeof(TBITMAPINFOHEADER);
    biWidth         := DIBWidth;    // Largeur de l'image en pixels
{$IFNDEF TOPDOWN}
    biHeight        := DIBHeight;   // De bas en haut : stupide mais incontournable  :-(
{$ELSE}
    biHeight        := - DIBHeight; // Win32 doesn't manage correctly these DIBs
{$ENDIF}
    biPlanes        := 1;           // Toujours un seul plan
    biBitCount      := DIBBPP;      // Bits par Pixels
    biCompression   := BI_RGB;      // Pour toutes les résolutions sauf 16 bits Cf ci-dessous
    biSizeImage     := DIBSize;
    biXPelsPerMeter := 0;
    biYPelsPerMeter := 0;
    biClrUsed       := 0;
    biClrImportant  := 0;
    If (PF=DUpf16) then begin //5-6-5 16-bit image : Masques = 0x001F/0x07E0/0xF800.
      biCompression := BI_BITFIELDS; // On utilise les masques
      RedMask       := $F800; // Red   Mask
      GreenMask     := $07E0; // Green Mask
      BlueMask      := $001F; // Blue  Mask
    End;
  End;
  If (PF<=DUpf8) Then Begin
    DIBhpalette:= CreatePalette(TLogPalette(pLogPalette^));
    SelectPalette(DIBDC,DIBhpalette,false);
    For      E := 0 to LastCoul[PF] do DIBheader.Indices[E] := E;
    E          := DIB_PAL_COLORS
  End Else E   := 0;
{$IFDEF VER90}
  DIBhandle    := CreateDIBSection(DIBDC,pBitmapInfo(@DIBheader)^,E,DIBbits,nil,0);
{$ELSE }
  DIBhandle    := CreateDIBSection(DIBDC,pBitmapInfo(@DIBheader)^,E,DIBbits,0,0);
{$ENDIF}
  DIBAdr := DIBBits;
{$IFNDEF TOPDOWN}
  Dec ( I(DIBAdr), (DIBHeight-1) * DIBWidth_b );
{$ENDIF}
  if (DIBhandle = 0) then raise DIB_ERROR.create(DIBErr1);
  SelectObject (DIBDC, DIBhandle);
  Cnv.handle   := DIBDC;
  CnvOK        := True; // OK We can draw on ...
End;

procedure TDIBUltra.SaveToStream(AStream : TStream ; SavingMode : TSaveMode ; FinalBpp : TDUPixelFormat);
var
  Info      : TCompressedDIBFileHeader;
  pLogPal   : ^T256ColorsPalette;
  cp        : Integer;
  DIBPos    : Integer;
  SysPal    : Boolean;
  AlphaChar : Byte;
  EndWord   : Word;
  Stream    : TMemoryStream;
  LZH       : TLZH; // Objet de compression
  LZHStream : TMemoryStream;

  T1, T2, T3, T4, T5, T6 : Longint;


Begin // 2 Modes de sauvegarde : SaveAsWindowsDIB & SaveAsUltraDIB
{$IFDEF NEVER_DEFINED}

// Définition de l'enregistrement DIBUltra :

  4 parties :

  Header  : TCompressedDIBFileHeader (Size = 20)
  Palette : Array[1..Header.Col] of (array[Red,Green,Blue] of Byte) // Si Besoin
  BitField: Champs de bytes compressés
  EndOfDIB: $4DFE // Code de fin d'image

  {Header} :
    ID   : Identifiant = $4DFE
    PF   : Bit 7 : 1=Palette systeme ; Bit 6..0=TDUPixelFormat
    Col  : Nombres d''entrées dans la table des couleurs (=0 si PF>DUpf8)
    Wd   : Largeur de la DIB Décompressée
    Ht   : Hauteur de la DIB Décompressée
    Typ  : Type de la DIB : pas complètement implémenté (normal, transparent, Alpha, Animate ...)
    Trsp : Transparent Color Index
    LZH  : A-t-on un flux compressé par LZH !
    Res1 : Reservé doit être de $00 !
    Res2 : Reservé doit être de $00000000 !
    Size : Taille en octets du champ d''octets compressé

  ## A partir de ce point, si la compression LZH est activée lors de la sauvegarde,
  ## les octets qui suivent sont encodé LZH
  ## Il faut décoder le flux pour lire normalement cette structure !

  {Palette} :
    Comporte Header.Col entrées de 3 bytes : Red, Green, Blue {Champ facultatif dans certains cas}

  {Cluster} :
    Stockage de la valeur $4DFE (fUltraDIB)
    Lors du décodage, tout autre code lance une exception 'Internal Error During CompressedDIB Loading Process !'

  {BitField} :

    Automate de Moore : 2 états : Normal State & Compression State
    Initialisation en Normal State.

    Normal State :
      #A : Les valeurs des pixels se suivent les uns à la suite des autres.
      #B : Un Code ESCCode ($FF) débraye en mode Compression sauf si il est à nouveau suivit d''un ESCCode
      #C : Pour deux ESCCode qui se suivent, un seul pixel de valeur ESCCode est déduit

    Compression State :
      #A : Un octet d''information précède une valeur de pixel à multiplier
           => Bits 7..6 :
             00=l''octet qui suit le pixel est à nouveau un octet compressé
             01=l''octet qui suit le pixel est normal, celui d''après est compressé
             10=les 2 octets qui suivent le pixel sont normaux, celui d''après est compressé
             11=les 3 octets qui suivent le pixel sont normaux, on repasse en mode normal pour les suivants
           => Bits 5..0 :
             000000 : Indique la fin de l''image
             000001 : réservé
             autres valeurs : nombre de répétitions du pixels suivant

  {EndOfDIB} :
    Stockage de la valeur $4DFE (fUltraDIB)
    Lors du décodage, tout autre code lance une exception 'Abnormal CompressedDIB Loading Terminaison !'

  {AlphaMask}
    Les octets qui suivent se rapportent au masque Alpha. (Cf AlphaTool)

{$ENDIF}
  If (SavingMode=DUsmDIBUltra) Then
  Begin
    // Sauvegarde au format UltraDIB Compressé
    Stream  := TMemoryStream.Create;
    Try
      {$IFNDEF TOPDOWN}
      YFlipping;// Flip DIB
      {$ENDIF}
      If (DUtAlpha in DIBStatus) AND (DIBResol<>DUpf8) Then
        Exception.Create('Only 256 colors (or less) UltraDIBs can be saved with AlphaChannels !');
//      If (DIBWidth MOD SizeOf(LongInt))<>0 Then
      OptimizeDIB; // None visible image modification
      Stream.SetSize(Self.DIBSize); // Au pire
      Stream.Position := 0;
      EndWord   := fUltraDIB;
      Info.Typ  := DIBStatus - [DUtSysPalette];
      Info.ID   := fUltraDIB;
      Info.Wd   := DIBWidth;
      Info.Ht   := DIBHeight;
      Info.StF  := DIBresol;
      Info.ExF  := FinalBpp;
      Info.Trsp := DIBTransp;
      Info.Res1 := 0;
      Info.Res2 := 0;
      If (DUtAlpha in DIBStatus) Then Info.ExF := DUpf16;
      If (DIBresol>DUpf8) Then SysPal := True
      Else Begin
        Info.Col:= (DIBLogPal.palNumEntries);
        SysPal  := (LastCoul[DIBResol]+1)=DIBLogPal.palNumEntries;
        pLogPal := nil;
        GetValidPalette (DIBResol, Pointer(pLogPal));
        If SysPal Then // Si on a le même nombre d'entrées
          For cp:= 0 To (LastCoul[DIBresol]-1) Do
            If ((DIBLogPal.palPalEntry[cp].peRed   <> pLogPal.palPalEntry[cp].peRed  )
              OR(DIBLogPal.palPalEntry[cp].peGreen <> pLogPal.palPalEntry[cp].peGreen)
              OR(DIBLogPal.palPalEntry[cp].peBlue  <> pLogPal.palPalEntry[cp].peBlue ))
            Then Begin SysPal := False; Break End;
        If SysPal Then // Pas besoin de stocker cette palette, c'est la palette système !
          Info.Typ := Info.Typ + [DUtSysPalette];
      End;
      If SysPal Then Info.Col:= 0 // Sinon exportation des valeurs de palette
                Else For cp := 0 To (Info.Col-1) Do Stream.Write(DIBLogPal.palPalEntry[cp],3);
      Stream.Write(EndWord, SizeOf(EndWord)); // Cluster of DIB = $4DFE
      // Now, we must write the compressed image to the stream
      DIBPos  := Stream.Position;

T1 := GetTickCount;

      // RLE/INC/NO Compression ?
      If (DUnoRLE in DIBStatus) Then
      If (DUINC   in DIBSTATUS) Then
        SebINCFilter (DIBBITS , DIBWidth, DIBHeight , Stream, True )  // Write The INC compressed DIB on the Tmp Stream
      Else
        Stream.WriteBuffer(DIBBITS^, DIBSize)        // Copie directe de la DIB dans le buffer
      Else
        SebRLECompress (DIBBits , DIBSize , Stream); // Write the RLE compressed DIB on the Tmp Stream

T2 := GetTickCount;
//MessageDlg('Temps de compression RLE/INC : '+Copy(FloatToStr((T2-T1)/1000),0,6)+'secondes.',mtInformation,[mbOk], 0);


      Info.Size := Stream.Position - DIBPos;
      // We put a EndOfFile Code :
      Stream.Write(EndWord, SizeOf(EndWord)); // End of DIB = $4DFE
      // Encoding the DIB is finished, we can encode the Alpha Channels
      If (Alpha<>nil) Then Begin
        AlphaChar := fAlphaInfo;
        Stream.WriteBuffer(AlphaChar, SizeOf(AlphaChar)); // Cluster
        Stream.WriteBuffer(Alpha^,Alpha.Header.TotalSz+SizeOf(TAlphaMaskHeader)); // Alpha Struct
        Stream.WriteBuffer(AlphaChar, SizeOf(AlphaChar)); // Cluster
      End;
      // OK c'est terminé pour les données. Une petite compression par dessus ?

T3 := GetTickCount;

      If (DUtLZH in DIBStatus) Then Begin // L'utilisateur désire-t-il une surcompression LZH ?
        DIBPos             := Stream.Position;
        Stream.Position    := 0;
        LZHStream          := TMemoryStream.Create;
        LZHStream.Position := 0;
        LZHStream.SetSize (DIBPos); // Par sécurité (mais cela ne s'appelle plus de la compression)
        LZH                := TLZH.Create;
        LZH.InputStream    := Stream;
        LZH.OutputStream   := LZHStream;
        LZH.Compress(DIBPos); // Nb d'octets à compresser
        LZH.Free; // Job terminé
        // On swappe les deux flux temporaires : (ruse)
        Stream.Free;
        Stream             := LZHStream; // sera libéré à la place de l'autre
//        MessageDlg('Taille du fichier compressé : '+IntToStr(Stream.Position)+' Octets.',mtInformation,[mbOk], 0);
        // Il faut couper l'excédent !
      End;

T4 := GetTickCount;
//MessageDlg('Temps de compression LZH : '+Copy(FloatToStr((T4-T3)/1000),0,6)+'secondes.',mtInformation,[mbOk], 0);
//SeeStats;
T5 := GetTickCount;

      // Recopie dans le Stream Client !
      DIBPos := Stream.Position;
      Stream.Position := 0;
      // Exportation du record CompressedDIBFileHeader dans le Stream Client
      AStream.Write(Info, SizeOf(Info));
      // Exportation du reste des infos dans le Stream Client
      AStream.CopyFrom(Stream, DIBPos);

T6 := GetTickCount;
//MessageDlg('Temps de recopie des flux : '+Copy(FloatToStr((T6-T5)/1000),0,6)+'secondes.',mtInformation,[mbOk], 0);

    Finally
      Stream.Free; // Retourne chez ta maman...
      {$IFNDEF TOPDOWN}
      YFlipping;// Flip DIB
      {$ENDIF}
    End;
    // OK It's completly finished !
  End Else Begin
    // Sauvegarde au format Windows
    Info.ID := fBM;
    Raise Exception.Create('Saving in Windows DIB Format is not yet supported (boring format...)');
  End;
End;

Procedure TDIBUltra.BuildDIB(AStream: TStream);
var
// T1,T2 : LongInt;
  TmpStream   : TMemoryStream;
  LZH         : TLZH;
  Stream      : TStream;
  pLogPalette : Pointer;
  TmpBmp      : TBitmap;
  TmpDU       : TDIBUltra;
  StreamPos   : integer; // To save stream position
  N           : integer; // Byte number in Buffer
  BRead       : Integer; // Number of Bytes readed
  cp          : integer; // compteur
  EndWord     : Word   ; // Check last word
  DUIB        : Boolean; // UltraDIB or WindowsDIB Format ?
  Buffer      : MultiTypeHeader;
  AlphaByte   : Byte;
  AlphaStruct : TAlphaMaskHeader;
Begin
  Stream := AStream; // Par défaut on associe les 2 (faux si LZHOk)
  Try
    BRead := BufSiz; If (AStream.Size<BRead) Then BRead := AStream.Size;
    StreamPos := AStream.Position + SizeOf(TCompressedDIBFileHeader); // Juste après le DIB Header
    AStream.Read(Buffer, BRead);
    AStream.Position := StreamPos; // On se prépare à la lecture des couleurs
    Case Buffer.UltraDIB.ID Of
      fBM       : DUIB := False;   // OK Windows DIB Format
      fUltraDIB : DUIB := True ;   // OK UltraDIB Format
      else Raise Exception.Create('DIB File Format Unrecognized !'); // Invalid Format !
    End;
    If DUIB Then Begin
      // UltraDIB Format
      // Is the stream LZH compressed ?
      If (DUtLZH in Buffer.UltraDIB.Typ) Then Begin // YES !
        TmpStream := TMemoryStream.Create;
        TmpStream.Position := 0;
        // UnLZH AStream into TmpStream.
        AStream.Position := StreamPos;
        AStream.ReadBuffer(N,SizeOf(LongInt)); // Le premier DWORD contient la taille décompressée
        TmpStream.SetSize(N);                  // Optimisation pour éviter de multiples allocations
        AStream.Position := StreamPos;         // Repositionnement
        LZH              := TLZH.Create;
        LZH.InputStream  := AStream;
        LZH.OutputStream := TmpStream;
        LZH.Decompress;  // GO !
        LZH.Free;        // Libération
        Stream           := TmpStream; // On switche
        Stream.Position  := 0; // Prêt pour lire la table des couleurs
        AStream.Free;    // On libère celui là
      End;
      // ## NOW THE STREAM IS TMPSTREAM (CompressedDIB) OR ASTREAM (Normal DIB) ##
      // Get The System Palette Info
      pLogPalette := nil;
      DIBStatus   := Buffer.UltraDIB.Typ;
      // Set N just after the CompressedDIBFileHeader record.
      If (Buffer.UltraDIB.StF<=DUpf8) Then // Palette useful
        If (DUtSysPalette in Buffer.UltraDIB.Typ)
          Then GetValidPalette(Buffer.UltraDIB.StF, pLogPalette)
          Else Begin // Palette dans le fichier
            DIBLogPal.palVersion    := $300; // Magic Number
            DIBLogPal.palNumEntries := Buffer.UltraDIB.Col;
            For cp:= 0 To (Buffer.UltraDIB.Col-1) Do
              With DIBLogPal Do Begin // Importation des valeurs de palette
                Stream.ReadBuffer(DIBLogPal.palPalEntry[cp].peRed,3);
                DIBLogPal.palPalEntry[cp].peFlags := 0;
              End;
            pLogPalette := @DIBLogPal;
          End;
      // OK now, we can create the empty DIB ! (Extend Pixel Format)
      With Buffer.UltraDIB Do Begin
        CreateDIB(Wd, Ht, ExF, pLogPalette); // Création d'une image ; Celle ci est l'UltraDIB
        If (StF<>ExF)
        Then TmpDU := TDIBUltra.Create(Wd, Ht, StF, pLogPalette) // Celle ci est une UltraDIB Temporaire
        Else TmpDU := Self;
      End; // Now, we must fill it
      // Vérification du cluster intermédiaire
      Stream.Read(EndWord, SizeOf(EndWord));
      If (EndWord<>fUltraDIB) Then raise Exception.Create('Internal Error During CompressedDIB Loading Process !');
// T1 := GetTickCount;
      With Buffer.UltraDIB Do
      If (DUnoRLE in Typ) Then
      If (DUINC   in Typ) Then
        SebINCFilter(TmpDU.DIBBITS, Wd, Ht, Stream, False )  // Décompression INC
      Else
        Stream.ReadBuffer(TmpDU.DIBBITS^, TmpDU.DIBSize) // Copie directe du buffer dans la DIB
      Else
        SebRLEDecompress(Stream, Size, TmpDU.DIBBITS); // Décompression RLE
      If (Buffer.UltraDIB.StF<>Buffer.UltraDIB.ExF) Then Begin
        Cnv.CopyRect(Rect(0,0,DIBWidth,DIBHeight),TmpDU.Canvas,Rect(0,0,DIBWidth, DIBHeight));
        TmpDU.Free; // Recopie de l'image Tmp sur l'autre (de résolution différente) et libération
      End;
// T2 := GetTickCount; Application.Title := 'Décompression RLE en '+IntToStr(T2 - T1)+' ms.';
      // Vérification de la fin
      Stream.Read(EndWord, SizeOf(EndWord));
      If (EndWord<>fUltraDIB) Then raise Exception.Create('Abnormal CompressedDIB Loading Terminaison !');
      // OK It's finished for conventionals compressed DIBs !
      {$IFNDEF TOPDOWN}
      YFlipping;// Flip DIB
      {$ENDIF}
      If (DUtAlpha in Buffer.UltraDIB.Typ) Then Begin
        // Now it's Alpha DIB hacking !
        Stream.Read(AlphaByte, SizeOf(AlphaByte));
        If (AlphaByte<>fAlphaInfo) Then raise Exception.Create('Internal Error During AlphaStructure Loading Process !');
        Stream.ReadBuffer(AlphaStruct,SizeOf(AlphaStruct));
        Stream.Position := Stream.Position - SizeOf(AlphaStruct);
        GetMem(Alpha, SizeOf(TAlphaMaskHeader) + AlphaStruct.TotalSz); // OK, Alpha is <> nil
        Stream.ReadBuffer(Alpha^,SizeOf(TAlphaMaskHeader) + AlphaStruct.TotalSz);
        Stream.Read(AlphaByte, SizeOf(AlphaByte));
        If (AlphaByte<>fAlphaInfo) Then raise Exception.Create('Abnormal AlphaStructure Ending !');
      End;
    End Else Begin
      // Windows DIB Format

      // Okay... It is not optimized :
      // I allocate a normal TBitmap object to load the Windows DIB file
      // I bitblit it on a new UltraDIB (with a good palette)
      // And I destroy the normal TBitmap.
      //
      // But it was really boring to do again what Borland have done yet (and nicely of course) !
      //
      TmpBmp := TBitmap.Create;
      Try
        With Buffer.UltraDIB Do Case Buffer.HDIBInfoHeader.biBitCount Of
          1 : ExF := DUpf1;
          4 : ExF := DUpf4;
          8 : ExF := DUpf8;
          16: If (Buffer.HDIBInfoHeader.biCompression=BI_BITFIELDS) Then ExF := DUpf16 else ExF := DUpf15;
          24: ExF := DUpf24;
          32: ExF := DUpf32;
          Else Raise Exception.Create('Unsupported WindowsDIB Resolution');
        End;
        Stream.Position    := Stream.Position - SizeOf(TCompressedDIBFileHeader); // Seek to beginning of the DIB
        TmpBmp.LoadFromStream(Stream);
        Buffer.UltraDIB.Wd := TmpBmp.Width;
        Buffer.UltraDIB.Ht := TmpBmp.Height;
        // OK now, we can create the empty DIB !
        DIBLogPal.palNumEntries := GetPaletteEntries(TmpBmp.Palette, 0, 255, DIBLogPal.palPalEntry );
        DIBLogPal.palVersion    := $300; // Magic Number
        pLogPalette := @DIBLogPal;
        With Buffer.UltraDIB Do CreateDIB(Wd, Ht, ExF, pLogPalette);
        // And fill the UltraDIB :
        Cnv.CopyRect(Rect(0,0,DIBWidth,DIBHeight),TmpBmp.Canvas,Rect(0,0,DIBWidth, DIBHeight));
      finally
        TmpBmp.Free; // Thank you for that service
      End;
    End;
  // And Whatever the format is :
  Finally
    Stream.Free; // No more useful now
  End;
End;

procedure TDIBUltra.OptimizeDIB;
var
  FirstInvisible : Integer;
  LastInvisible  : Integer;
  Line, Pixel    : Integer;
  Adr            : ^PxlB; // Array of Byte;
  LastVisible    : Byte;
Begin
{ OPTIMISATION DES CODAGES DE COMPRESSION EN FONCTION DE LA RESOLUTION }
  Case DIBResol of
    DUpf1, DUpf4  : DIBStatus := DIBStatus + [DUnoRLE]   - [DUINC]; // 2 et 16 couleurs
    DUpf8         : DIBStatus := DIBStatus + [] - [DUnoRLE, DUINC]; // 256 couleurs
//  DUpf8         : DIBStatus := DIBStatus + [DUINC]     - [DURLE]; // Niveaux de gris
    DUpf15,DUpf16 : DIBStatus := DIBStatus + [DUnoRLE]   - [DUINC]; // 32000 et 65000 couleurs
    DUpf24        : DIBStatus := DIBStatus + [DUINC, DUnoRLE] - []; // 16,7 Millions de couleurs
    DUpf32        : DIBStatus := DIBStatus + [DUnoRLE]   - [DUINC]; // 16,7 M° + Alpha couleurs
    Else
  End; // La compression LZH est laissée à l'appréciation de l'utilisateur

  FirstInvisible := (DIBWidth * DIBBPP + 7) shr 3; // First visible byte
  LastInvisible  := Abs(DIBWidth_b);
  If (LastInvisible=FirstInvisible) Then Exit;        // No optimisation possible
  Adr := DIBAdr;
  Dec(FirstInvisible);
  Dec(LastInvisible );
  For Line := 0 To (DIBHeight-1) Do Begin
    LastVisible := Adr^[FirstInvisible-1];
    For Pixel := FirstInvisible To LastInvisible Do Adr^[Pixel] := LastVisible;
    Inc( I(Adr), DIBWidth_b );
  End;
End;

procedure TDIBUltra.WLZH (Val : Boolean);
Begin
  If Val Then DIBStatus := DIBStatus + [DUtLZH]
         Else DIBStatus := DIBStatus - [DUtLZH];
End;

Function TDIBUltra.RLZH : Boolean;
Begin
  Result := DUtLZH in DIBStatus ;
End;

procedure TDIBUltra.DrawOn  (Dest : TRect ; Canevas : TCanvas ; Xsrc, Ysrc : Integer );
var W,H,P : I;
Begin
  If Not CnvOK Then Exit;
  If (Xsrc<0) Then Begin Dec(Dest.Left, Xsrc) ; Inc(Dest.Right  {Width }, Xsrc) ; Xsrc := 0 End;
  If (Ysrc<0) Then Begin Dec(Dest.Top,  Ysrc) ; Inc(Dest.Bottom {Height}, Ysrc) ; Ysrc := 0 End;
  BitBlt( Canevas.Handle, Dest.Left, Dest.Top, Dest.Right, Dest.Bottom, Cnv.Handle, Xsrc, Ysrc, SRCCOPY);
End;

procedure TDIBUltra.TiledOn(Const Dest : TRect; Canevas : TCanvas);
var
  x , y  : Integer;
  n , m  : Integer;
  Mx, My : Integer;
  IniLeft: Integer;
  aDest : TRect;
Begin
  // Bug killed by Stephane : svdb <svdb@free.fr> : Thanks
  If Not CnvOK Then Exit;

  aDest := Dest;
  x := aDest.Right  { Width } Div DIBWidth ; { Nb horizontal tiles }
  y := aDest.Bottom { Height} Div DIBHeight; { Nb vertical tiles }
  Mx := aDest.Right - aDest.Left;  { Width }
  My := aDest.Bottom - aDest.Top; { Height}
  IniLeft := aDest.Left;
  For n := 0 To y Do { Width }
  Begin
    If ((aDest.Bottom - aDest.Top) > My)
      Then aDest.Right := My - aDest.Left
      Else aDest.Right := DIBWidth;

    For m := 0 To x Do { Height }
    Begin
      If ((aDest.Right - aDest.Left) > Mx)
        Then aDest.Bottom := Mx - aDest.Top
        Else aDest.Bottom := DIBHeight;

      DrawOn(aDest, Canevas, 0, 0);
      Inc(aDest.Left, DIBWidth);
    End; { For }

    aDest.Left := IniLeft;
    Inc(aDest.Top, DIBHeight);
  End; { For }
End;

procedure TDIBUltra.StretchOn (Dest : TRect ; Canevas : TCanvas);
Begin
  If Not CnvOK Then Exit; // It was buggy too, thank you Boris Daljevic !
  StretchBlt(Canevas.Handle, Dest.Left, Dest.Top, Dest.Right-Dest.Left, Dest.Bottom-Dest.Top,
             Cnv.Handle, 0, 0, DIBWidth-1, DIBHeight-1, SRCCOPY);
End;

procedure TDIBUltra.BufferToUpdate;
Begin
  Client := nil;
End;

Function TDIBUltra.BufferOf ( AOwner : TObject) : Boolean;
Begin // Routine de Buffering
  Result := (Client=AOwner);
  Client := AOwner;
End;

procedure TDIBUltra.BufferDim (Width, Height : Word);
Begin
  ClpRect := Rect(0,0,Width, Height);
  If (DIBWidth>=Width) AND (DIBHeight>=Height) Then Exit; // Pas de Pb de dimension
  DeleteObject (DIBhpalette);
  DeleteObject(DIBhandle);
  If (DIBWidth <Width ) Then DIBWidth  := Width;
  If (DIBHeight<Height) Then DIBHeight := Height;
  CreateDIB(Width, Height, DIBResol, @DIBLogPal);
  Client := nil;
End;

procedure TDIBUltra.SaveToFile(const Filename: string ; SavingMode : TSaveMode ; FinalBpp : TDUPixelFormat);
var Stream: TStream;
begin
  Stream := TFileStream.Create(Filename, fmCreate);
  try SaveToStream(Stream, SavingMode, FinalBpp);
  finally Stream.Free;
  end;
End;

Function  TDIBUltra.GetScanLine (R : Integer) : Pointer;
Begin
  If (R<0)OR(R>=DIBHeight) Then Begin Result := nil; Exit End; // Ligne invalide
  Result := Pointer(I(DIBAdr) + (DIBWidth_b * R));
End;

Type
  TPaletteEntries = array[0..255] of TPaletteEntry;
  TRGBQuads       = array[0..255] of TRGBQuad;

procedure TDIBUltra.SetPalette(pLogPalette : Pointer);
// I have not tested this function
// May be it works, may be not ...
// Je n'ai pas eu le temps de tester cette fonction
// Cela marche peut être - peut être pas... (surement pas)
var
  TmpRGBQuad : TRGBQuads;
  Tmp        : TRGBQuad;
  n          : Integer;
begin
  If (DIBResol>DUpf8) Then Exit;
  DeleteObject(DIBhpalette);
  {
  For n := 0 To TLogPalette(pLogPalette^).palNumEntries Do
  Begin
    DIBLogPal.palPalEntry[n] := TLogPalette(pLogPalette^).palPalEntry[n];
    ASM
      MOV   EAX, [TLogPalette(pLogPalette).palPalEntry[n]]
      BSWAP EAX
      SHL   EAX, 8
      MOV Tmp, EAX
    End;
    TmpRGBQuad[n] := Tmp;
  End;
  }
  DIBhpalette             := CreatePalette(TLogPalette(pLogPalette^));
  DIBLogPal.palNumEntries := TLogPalette(pLogPalette^).palNumEntries;
  SetDIBColorTable(DIBDC,0,DIBLogPal.palNumEntries,TmpRGBQuad);
  SelectPalette(DIBDC,DIBhpalette,false);
end;

procedure TDIBUltra.SetClipRect(R : TRect);
Begin
  ExitClip := False;
  If (R.Left<0)            Then ClpRect.Left   := 0            Else ClpRect.Left   := R.Left;
  If (R.Top <0)            Then ClpRect.Top    := 0            Else ClpRect.Top    := R.Top ;
  If (R.Right >=DIBWidth ) Then ClpRect.Right  := DIBWidth -1  Else ClpRect.Right  := R.Right;
  If (R.Bottom>=DIBHeight) Then ClpRect.Bottom := DIBHeight-1  Else ClpRect.Bottom := R.Bottom;
  If (ClpRect.Left>ClpRect.Right ) Then ExitClip := True;
  If (ClpRect.Top >ClpRect.Bottom) Then ExitClip := True;
  CantDraw := ExitClip OR ExitMask OR ExitWidth OR ExitMode;
End;

procedure TDIBUltra.SetWidthPen(PWdth : LongInt);
Begin
  WidthPen := PWdth;
  If (WidthPen=0) Then ExitWidth := True Else ExitWidth := False;
  CantDraw := ExitClip OR ExitMask OR ExitWidth OR ExitMode;
End;

procedure TDIBUltra.SetMode (M : TDUPenMode);
Begin
  Mode := M;
  If (M = DUpmNOP) Then ExitMode := True Else ExitMode := False;
  CantDraw := ExitClip OR ExitMask OR ExitWidth OR ExitMode;
End;

procedure TDIBUltra.ClearAll;
Begin
  Cnv.Brush.Color := ColorBrh;
  Cnv.FillRect(Rect(0,0,DIBWidth, DIBHeight));
End;

{$IFDEF NEVER_DEFINED} // Il y a un Bug, on met cette procedure de coté !
var EAX, EDI, ESI, EBX, EBP : LongInt; // To Save & Restaure Registers
procedure TDIBUltra.ClearAll; assembler;
ASM
// [Self] == [EAX] ! Careful / Do not overwrite EAX
  MOV CL,  [Self].DIBResol
  CMP CL,  DUpf24
  JZ  @FillRect24Bits
  MOV ECX, [Self].DIBSize
  SHR ECX, 2 // On traite 4 bytes par 4 Bytes
  MOV EDX, [Self].DIBBits
  MOV EAX, [Self].BCoulL
  @DO:
    MOV [EDX + 4 * ECX], EAX
  LOOP @DO
  JMP @END

@FillRect24Bits:
  MOV &ESI, ESI
  MOV &EDI, EDI
  MOV &EBX, EBX
  MOV &EBP, EBP

  MOV ESI, [Self].DIBWidth_b
  SHR ESI, 2 // On traite 4 bytes par 4 Bytes
  MOV EDI, [Self].DIBBits
  MOV EBP, [Self].DIBHeight
  // ESI : nb max de DD dans une ligne
  // EDI : adresse de destination en écriture
  // EAX, EBX, ECX = Couleur1, Couleur2, Couleur3
  // Il faut : BBRRVVBB , VVBBRRVV , RRVVBBRR
  // Dans    :    EAX   ,    EBX   ,   ECX
  MOV EDX, [Self].BCoulL  // Et BCoulL = BBRRVVBB
  MOV EBX, EDX
  MOV BL,  BH
  ROR EBX, 8    // EBX Set
  MOV ECX, EBX
  MOV CL,  BH
  ROR ECX, 8    // ECX Set
  MOV EAX, EDX  // EAX Set / Self Erased
  // Cette boucle s'exécute au moins une fois :
  XOR EDX, EDX // Initialisation du compteur
  @DO24:
    MOV  [EDI + 4 * EDX], EAX
    INC EDX
    CMP EDX, ESI
    JZ  @NEXTLINE
    MOV  [EDI + 4 * EDX], EBX
    INC EDX
    CMP EDX, ESI
    JZ  @NEXTLINE
    MOV  [EDI + 4 * EDX], ECX
    INC EDX
    CMP EDX, ESI
    JNZ @DO24
  @NEXTLINE:
  LEA EDI, [EDI + ESI * 4]
  XOR EDX, EDX // Initialisation du compteur
  DEC EBP
  JNZ @DO24

@REGISTERRESTORE:
  MOV EBP, &EBP
  MOV EBX, &EBX
  MOV EDI, &EDI
  MOV ESI, &ESI
@END:
End;
{$ENDIF}

procedure TDIBUltra.ClearClipRect;
begin
  Cnv.Brush.Color := ColorBrh;
  Cnv.FillRect(Rect(ClpRect.Left,ClpRect.Top,ClpRect.Right+1,ClpRect.Bottom+1));
end;

procedure TDIBUltra.FillRect (R : TRect);
// Un bonne petite routine ASM fera bien l'affaire !
Begin
  If (R.Left   < ClpRect.Left  ) Then R.Left   := ClpRect.Left  ;
  If (R.Top    < ClpRect.Top   ) Then R.Top    := ClpRect.Top   ;
  If (R.Right  > ClpRect.Right ) Then R.Right  := ClpRect.Right ;
  If (R.Bottom > ClpRect.Bottom) Then R.Bottom := ClpRect.Bottom;
  Canvas.FillRect(R);
End;

//*******************************************************************//
//********** DEBUT DES ROUTINES DE MANIPULATION DU MASQUE ***********//
//*******************************************************************//

procedure TDIBUltra.SetMask (M : LongInt);
Begin
  Mask := M;
  If (M = DUpsClear) Then ExitMask := True Else ExitMask := False;
  CantDraw := ExitClip OR ExitMask OR ExitWidth OR ExitMode;
End;

Function TDIBUltra.PenPos: TPoint;
Begin
  Result:= Point(X, Y);
End;

Function TDIBUltra.ReleaseHandle: THandle;
Begin
  Result:= DIBHandle;
  DIBHandle:= 0;
End;

procedure TDIBUltra.RotateStyle (n : Byte); assembler; // Rotate le masque (n Modulo 32) fois
asm
  MOV  CL, n
  ROL  [Self].Mask, CL
End;

function  TDIBUltra.PlotON : Boolean; assembler;
asm
  MOV  Result, True
  ROL [Self].Mask, 1
  JC   @End
  MOV  Result, False
@End: End;

procedure TDIBUltra.PrepareStyle; assembler; // Rotate le masque jusqu'à présenter un point imprimable
asm
  MOV  EAX,         [Self].Mask
  BSR  ECX,         EAX
  SUB  ECX,         31
  NEG  ECX
  ROL  [Self].Mask, CL
End;

//*******************************************************************//
//*********** FIN DES ROUTINES DE MANIPULATION DU MASQUE ************//
//*******************************************************************//

//*******************************************************************//
//**** DEBUT DES ROUTINES D'AFFECTATION DU PINCEAU ET DU STYLO ******//
//*******************************************************************//

Function  TDIBUltra.GetColorFromIndex(Idx : LongInt) : TColor;
Begin
  Case DIBResol of
    DUpf1, DUpf4,
    DUpf8  : Result := DIBLogPal.Color[Idx];//ASM MOV EAX, Self.DIBLogPal.Color[Idx] End;
    // Point : 0RRRRRVV VVVBBBBB ; Masque  : $7C00 $03E0 $001F ===> $00 $BB $VV $RR
    DUpf15 : ASM MOV EAX, Idx; MOV ECX, EAX; MOV EDX, EAX; AND AX,$7C00; AND CX,$03E0; AND DX,$001F;
                 SHR EAX, 8-1; SHL ECX, 3+3; SHL EDX, 3+16;OR  EAX, ECX; OR  EAX, EDX; MOV Result, EAX End;
    // Point : RRRRRVVV VVVBBBBB ; Masque  : $F800 $07E0 $001F ===> $00 $BB $VV $RR
    DUpf16 : ASM MOV EAX, Idx; MOV ECX, EAX; MOV EDX, EAX; AND AX,$F800; AND CX,$07E0; AND DX,$001F;
                 SHR EAX, 8-0; SHL ECX, 3+2; SHL EDX, 3+16;OR  EAX, ECX; OR  EAX, EDX; MOV Result, EAX End;
    DUpf24,  // $00 $RR $VV $BB ==> $00 $BB $VV $RR
    DUpf32 : ASM MOV EAX, Idx; BSWAP EAX; SHR EAX, 8; MOV Result, EAX End;
  End;
End;

Function  TDIBUltra.GetIndexFromColor(Coul : LongInt) : TColorIndex;
Begin
  Case DIBResol of
    DUpf1, DUpf4,
    DUpf8  : Result := GetNearestPaletteIndex(DIBHPalette, Coul);
    // $00 $BB $VV $RR ==> WORD : 0RRRRRVV VVVBBBBB ; Masque : $7C00 $03E0 $001F
    DUpf15 : ASM MOV EAX, Coul; MOV ECX, EAX; MOV EDX, EAX; SHL EAX, 8-1; SHR ECX, 3+3; SHR EDX, 3+16;
                 AND EAX,$7C00; AND ECX,$3E0; AND EDX, $1F; OR  EAX, ECX; OR  EAX, EDX; MOV Result, EAX End;
    // $00 $BB $VV $RR ==> WORD : RRRRRVVV VVVBBBBB ; Masque : $F800 $07E0 $001F
    DUpf16 : ASM MOV EAX, Coul; MOV ECX, EAX; MOV EDX, EAX; SHL EAX, 8-0; SHR ECX, 3+2; SHR EDX, 3+16;
                 AND EAX,$F800; AND ECX,$7E0; AND EDX, $1F; OR  EAX, ECX; OR  EAX, EDX; MOV Result, EAX End;
    DUpf24, // $00 $BB $VV $RR ==> $00 $RR $VV $BB
    DUpf32 : ASM MOV EAX, Coul; BSWAP EAX; SHR EAX, 8; MOV Result, EAX End;
  End;
End;

procedure TDIBUltra.SetPenColors(Idx : LongInt);
Begin
  // Affectation des Couleurs Indexées
  Case DIBResol of
    DUpf1          : Begin PCoulL := -(Idx AND 1); PCoulB := PCoulL End; // Réplication du bit 0
    DUpf4          : Begin PCoulB := Idx AND LastCoul[DIBResol]; PCoulB := PCoulB OR (PCoulB SHL 4);
                           PCoulL := PCoulB OR (PCoulB SHL 8);   PCoulL := PCoulL OR (PCoulL SHL 16) End;
    DUpf8          : Begin PCoulB := Idx AND LastCoul[DIBResol];
                           PCoulL := PCoulB OR (PCoulB SHL 8);   PCoulL := PCoulL OR (PCoulL SHL 16) End;
    DUpf15, DUpf16 : Begin PCoulW := Idx AND LastCoul[DIBResol]; PCoulL := PCoulW OR (PCoulW SHL 16) End;
    DUpf24         : Begin PCoulB := Idx; PCoulV := Idx SHR 8;   PCoulR := Idx SHR 16;
                           PCoulL := (Idx AND LastCoul[DIBResol]) OR PCoulB SHL 24 End;
    DUpf32         :       PCoulL := Idx AND LastCoul[DIBResol];
  End; // Le PCoulL doit être valide à cause d'un Plot par exemple
End;

procedure TDIBUltra.SetBrushColors(Idx : LongInt);
begin
  // Affectation des Couleurs Indexées
  Case DIBResol of
    DUpf1          : Begin BCoulL := -(Idx AND 1); BCoulB := BCoulL End; // Réplication du bit 0
    DUpf4          : Begin BCoulB := Idx AND LastCoul[DIBResol]; BCoulB := BCoulB OR (BCoulB SHL 4);
                           BCoulL := BCoulB OR (BCoulB SHL 8);   BCoulL := BCoulL OR (BCoulL SHL 16) End;
    DUpf8          : Begin BCoulB := Idx AND LastCoul[DIBResol];
                           BCoulL := BCoulB OR (BCoulB SHL 8);   BCoulL := BCoulL OR (BCoulL SHL 16) End;
    DUpf15, DUpf16 : Begin BCoulW := Idx AND LastCoul[DIBResol]; BCoulL := BCoulW OR (BCoulW SHL 16) End;
    DUpf24         : Begin BCoulB := Idx; BCoulV := Idx SHR 8;   BCoulR := Idx SHR 16;
                           BCoulL := (Idx AND LastCoul[DIBResol]) OR BCoulB SHL 24 End;
    DUpf32         :       BCoulL := Idx AND LastCoul[DIBResol];
  End; // Le BCoulL doit être valide à cause d'un ClearAll par exemple
End;

Function  TDIBUltra.GetPenColorIndex : TColorIndex ;
Begin
  Case DIBResol of
    DUpf1, DUpf4, DUpf8 : Result := PCoulB AND LastCoul[DIBResol];
    DUpf15,DUpf16       : Result := PCoulW AND LastCoul[DIBResol];
    DUpf24,DUpf32       : Result := PCoulL AND LastCoul[DIBResol];
    Else                  Result := 0;
  End;
End;

Function TDIBUltra.StdIndex (Cl : TDUColor) : TColorIndex; assembler;
Begin
  Result := StdClIdxArray[Cl,Ord(DIBResol)] ;
End;

procedure TDIBUltra.SetPenColorIndex (Idx : TColorIndex);
begin
  SetPenColors(Idx);
  // Affectation des Couleurs non Indexées & modification de la couleur courante
  ColorPen := GetColorFromIndex(Idx AND LastCoul[DIBResol]);
//  Canvas.Pen.Color := ColorPen; // Histoire de lier le DIBUltra Pen et le Canvas.Pen ##  TROP LENT !
End;

Function  TDIBUltra.GetBrushColorIndex : TColorIndex ;
Begin
  Result := BCoulL AND LastCoul[DIBResol];
End;

procedure TDIBUltra.SetBrushColorIndex (Idx : TColorIndex);
Begin
  SetBrushColors(Idx);
  // Affectation des Couleurs non Indexées & modification de la couleur courante
  ColorBrh := GetColorFromIndex(Idx AND LastCoul[DIBResol]);
//  Cnv.Brush.Color := ColorBrh; // Histoire de lier le DIBUltra Brush et le Canvas.Brush ##  TROP LENT !
End;

procedure TDIBUltra.SetPenColor (coul : TColor);
begin
  If (Coul = ColorPen) then exit; // Change la couleur du Stylo courant
  SetPenColors(GetIndexFromColor(Coul));
  ColorPen := Coul;
  Cnv.Pen.Color := Coul; // Histoire de lier le DIBUltra Pen et le Canvas.Pen
End;

procedure TDIBUltra.SetBrhColor (coul : TColor);
begin
  If (Coul = ColorBrh) then exit; // Change la couleur du Pinceau courant
  SetBrushColors(GetIndexFromColor(Coul));
  // Affectation des Couleurs non Indexées & modification de la couleur courante
  ColorBrh := Coul;
  Cnv.Brush.Color := ColorBrh; // Histoire de lier le DIBUltra Brush et le Canvas.Brush
End;

//*******************************************************************//
//***** FIN DES ROUTINES D'AFFECTATION DU PINCEAU ET DU STYLO *******//
//*******************************************************************//


//*******************************************************************//
//********* DEBUT DES ROUTINES DE GESTION DES POINTS  ***************//
//*******************************************************************//

Function TestPointInClipRect(X1,Y1 : Integer ; Clp : TRect) : Boolean ; stdcall;
ASM
  XOR  EAX, EAX  // AL va être utilisé pour les tests de la zone de clipping
  // Résultat : AL = 0000 XXXX ; X = 1 ou 0 en fonction de la zone
  MOV EDX, Clp.Bottom    // Préchargement des tampons
  MOV ECX, y1

  SUB EDX, ECX           // Temp = (YMax - Y)
  SHL EDX,1 ; RCL AL, 1  // Bit[3] = Signe(Temp)
  SUB ECX, Clp.Top       // Temp = (Y - YMin)
  SHL ECX,1 ; RCL AL, 1  // Bit[2] = Signe(Temp)

  MOV EDX, Clp.Right     // Préchargement des tampons
  MOV ECX, x1

  SUB EDX, ECX           // Temp = (Xmax - X)
  SHL EDX,1 ; RCL AL, 1  // Bit[1] = Signe(Temp)
  SUB ECX, Clp.Left      // Temp = (X - Xmin)
  SHL ECX,1 ; RCL AL, 1  // Bit[0] = Signe(Temp)

  MOV Result, True
  CMP EAX, 0
  JZ  @True
  MOV Result, False
  @True:
End;

procedure TDIBUltra.MoveTo (x1,y1 : Integer);
// Change la position courante du curseur graphique
Begin
  If (x1 <> NoChange) then X := x1;
  If (y1 <> NoChange) then y := y1;
end;

//*** SETPIXEL ROUTINES ***

procedure TDIBUltra.SetPixel (Nx, Ny : Integer; coul : TColor);
Begin
  If TestPointInClipRect(Nx,Ny,ClpRect) Then DirectPlot (Nx,Ny,GetIndexFromColor(Coul));
End;

procedure TDIBUltra.SetPixelIndex (Nx, Ny : Integer; Idx : TColorIndex);
Begin
  If TestPointInClipRect(Nx,Ny,ClpRect) Then DirectPlot (Nx,Ny,Idx);
End;

procedure TDIBUltra.Plot (Nx, Ny : Integer); // En moyenne 10 fois plus rapide que canvas.pixels...
Begin
  If (Nx<>NoChange) Then X := Nx;
  If (Ny<>NoChange) Then Y := Ny;      // Modification de la position du stylo
  If TestPointInClipRect(Nx, Ny, ClpRect) Then DirectPlot (Nx,Ny,PCoulL);
End;

Type  TShr4Bits = array [0..1] of byte;
const Shift4  : TShr4Bits = ($04,$00);
const Masque4 : TShr4Bits = ($0F,$F0);

Type  TShr1Bits = array [0..7] of byte;
const Shift1  : TShr1Bits = ($07,$06,$05,$04,$03,$02,$01,$00);
const Masque1 : TShr1Bits = ($7F,$BF,$DF,$EF,$F7,$FB,$FD,$FE);

procedure TDIBUltra.DirectPlot (Nx, Ny : Integer; ColIdx : TColorIndex );
var Adr, n : integer;
Begin
  Case DIBResol of
    DUpf1          : Begin Adr := (Nx div 8) + DIBWidth_b * Ny; n := (Nx AND 7);
                       PxlB(DIBAdr^)[Adr] := (PxlB(DIBBits^)[Adr] AND Masque1[n]) OR (NOT Masque1[n] AND (ColIdx shl Shift1[n])) End;
    DUpf4          : Begin Adr := (Nx div 2) + DIBWidth_b * Ny; n := (Nx AND 1);
                       PxlB(DIBAdr^)[Adr] := (PxlB(DIBBits^)[Adr] AND Masque4[n]) OR (NOT Masque4[n] AND (ColIdx shl Shift4[n])) End;
    DUpf8          :   PxlB(DIBAdr^)[Ny * DIBWidth_b   + Nx] := ColIdx;
    DUpf15, DUpf16 :   PxlW(DIBAdr^)[Ny * DIBHalfWidth + Nx] := ColIdx;
    DUpf24         : Begin n:= Ny*DIBWidth_b+3*Nx;
                       PxlB(DIBAdr^)[n+0]:= ColIdx ;
                       PxlB(DIBAdr^)[n+1]:= ColIdx shr 8;
                       PxlB(DIBAdr^)[n+2]:= ColIdx shr 16;
                     End;
    DUpf32         :   PxlL(DIBAdr^)[Ny * DIBWidth_b div 2 + Nx] := ColIdx;
  end;
End;

//*** GETPIXEL ROUTINES ***

Function TDIBUltra.GetPixelIndex (Nx, Ny : Integer) : TColorIndex; // Return the index of color (depends of bpp)
var adr : integer;
Begin
  Case DIBResol of
    DUpf1  : Result := 1  AND (PxlB(DIBAdr^)[(Nx div 8) + DIBWidth_b * Ny] shr Shift1[Nx AND 7]);
    DUpf4  : Result := 15 AND (PxlB(DIBAdr^)[(Nx div 2) + DIBWidth_b * Ny] shr Shift4[Nx AND 1]);
    DUpf8  : Result := PxlB(DIBAdr^)[Nx + DIBWidth_b * Ny];
    DUpf15, // The index is contained in 2 bytes. (idem DUpf16)
    DUpf16 : Result := PxlW(DIBAdr^)[1 * Nx + DIBHalfWidth * Ny];
    DUpf24 : Result := PxlL(DIBAdr^)[3 * Nx + DIBWidth_b * Ny] AND $FFFFFF;
    DUpf32 : Result := PxlL(DIBAdr^)[Nx + DIBWidth_b div 2 * Ny];
    Else Result := 0;
  End;
End;

Function  TDIBUltra.GetPixel (Nx, Ny : Integer): TColor; // Return a real color
var adr : integer;
Begin
  Case DIBResol of
    DUpf1, DUpf4, DUpf8 : Result := DIBLogPal.Color[GetPixelIndex(Nx, Ny)];
    DUpf15 : begin     // Point : 0RRRRRVV VVVBBBBB ; Masque  : $7C00 $03E0 $001F
      Result := PxlW(DIBAdr^)[Nx + DIBHalfWidth * Ny];
      Result := ((Result and $001F) shl 19) + ((Result and $03E0) shl 6) + (Result and $7C00) shr 7;
    end;
    DUpf16 : begin  // Point : RRRRRVVV VVVBBBBB ; Masque  : $F800 $07E0 $001F
      Result := PxlW(DIBAdr^)[Nx + DIBHalfWidth * Ny];
      Result := ((Result and $001F) shl 19) + ((Result and $07E0) shl 5) + (Result and $F800) shr 8;
    end;
    DUpf24 : begin
      adr := 3 * Nx + DIBWidth_b * Ny;
      Result := PxlB(DIBAdr^)[adr] * $10000 + PxlB(DIBAdr^)[adr+1] * $100 + PxlB(DIBAdr^)[adr+2];
    end;
    DUpf32 : begin
      Result := PxlL(DIBAdr^)[Nx + DIBWidth_b div 2 * Ny];
      Result := ((Result and $FF0000) shr 16) + ((Result and $FF) shl 16) + (Result and $FF00);
    end;
    else Result := 0;
  end;
End;

//*******************************************************************//
//*********** FIN DES ROUTINES DE GESTION DES POINTS  ***************//
//*******************************************************************//

procedure TDIBUltra.StepTo (dx,dy : Integer);
begin
  Lineto (X + dx, Y + dy);
end;

var
  Sg : TLine;
  PenteX, PenteY : Integer;

procedure TDIBUltra.LineTo (x2,y2 : Integer);
Type
  TPente = (Horizontale, Oblique, Verticale );
Var
  TmpMsk : LongInt;

  Function Pente : TPente; assembler;
  // Cette fonction en assembleur n'a pas d'autre intérêt que de présenter
  // une fonction simple asm. Le Compilo Delphi génère un code presque
  // identique et de toute façon, le gain de performance est minime.
  // Cette fonction met à jour PenteX et PenteY et rend le type de la pente du
  // Segment Sg. (Cf TPente)
  asm
      MOV PenteX, -1   // PenteX := -1;
      MOV PenteY, -1   // PenteY := -1;

      MOV EAX, Sg.y2   // Sg.dy  := Sg.y2 - Sg.y1;
      SUB EAX, Sg.y1
      JS  @PasYNEG
      NEG PenteY       // If (Sg.dy>=0) Then PenteY := -PenteY;
      @PasYNEG:
      MOV Sg.dy, EAX

      MOV EAX, Sg.x2   // Sg.dx  := Sg.x2 - Sg.x1;
      SUB EAX, Sg.x1
      JS  @PasXNEG
      NEG PenteX       // If (Sg.dx>=0) Then PenteX := -PenteX;
      @PasXNEG:
      MOV Sg.&dx, EAX

      BT  PenteX, 31   // PenteX négatif ?
      JNC @DXPOS
      NEG EAX          // (PenteX * Sg.dx)
      @DXPOS:

      BT  PenteY, 31   // PenteY négatif ?
      JC  @ADD
      SUB EAX, Sg.dy
      JMP @SUITEPENTE
      @ADD:
      ADD EAX, Sg.dy   // Enfin, on a (Seg.dx*PenteX)-(Seg.dy*PenteY);
      @SUITEPENTE:

      JZ  @PENTEOBLIQUE // droite à 45 degrés
      JS  @PENTEVERT    // droite plutôt verticale
      // JMP @PENTEHORZ // droite plutôt horizontale

      @PENTEHORZ:    MOV Result, Horizontale; JMP @EXIT
      @PENTEOBLIQUE: MOV Result, Oblique    ; JMP @EXIT
      @PENTEVERT:    MOV Result, Verticale  ; // JMP @EXIT

      @EXIT:
    End;

  procedure Line2W;
  Begin
    TmpMsk := Mask;
    Line; // Première ligne
    Mask   := TmpMsk;
    Case Pente Of
      Horizontale, // On se comporte comme le GDI (sinon on ferait Inc(Sg.y1, PenteX)... un peu + joli)
      Oblique    : Begin Dec(Sg.y1); Dec(Sg.y2) End;
      Verticale  : Begin Dec(Sg.x1); Dec(Sg.x2) End;
    End;
    Line; // Seconde ligne (décalée)
  End;

  procedure Line3W;
  var P : TPente;
  Begin
    TmpMsk := Mask;
    Line; // Première ligne
    P      := Pente;
    Mask   := TmpMsk;
    Case P Of
      Horizontale : Begin Dec(Sg.y1); Dec(Sg.y2) End;
      Oblique     : Begin Dec(Sg.y1,PenteY); Dec(Sg.y2,PenteY) End;
      Verticale   : Begin Dec(Sg.x1); Dec(Sg.x2) End;
    End;
    Line; // Seconde ligne (décalée)
    Mask   := TmpMsk;
    Case P Of
      Horizontale : Begin Inc(Sg.y1,2); Inc(Sg.y2,2) End;
      Oblique     : Begin
                      Inc(Sg.y1,PenteY); Inc(Sg.y2,PenteY);
                      Dec(Sg.x1,PenteX); Dec(Sg.x2,PenteX);
                    End;
      Verticale   : Begin Inc(Sg.x1,2); Inc(Sg.x2,2) End;
    End;
    Line; // Troisième ligne (décalée)
  End;

Begin // Cette fonction prend en charge les largeurs > 1 en émulant un seul tracé
  If (x2=NoChange) Then x2 := X;
  If (y2=NoChange) Then y2 := Y;      // Modification de la position du stylo
  If CantDraw Then
  Begin
    X := x2;
    Y := y2;
    Exit;
  End;
  Sg.x1 := X ; // Affectation des valeurs
  X     := x2;   // MAJ de X
  Sg.x2 := x2;
  Sg.y1 := Y ;
  Y     := y2;   // MAJ de Y
  Sg.y2 := y2;
  Case PenWidth Of
    1 : Line  ; // Largeur d'une ligne : 1 Pixel
    2 : Line2W; // Largeur d'une ligne : 2 Pixels
    3 : Line3W; // Largeur d'une ligne : 3 Pixels
    Else Begin  // Largeur > 3 pixels => je passe la main au GDI
      Canvas.Pen.Width := PenWidth; // Ce gros fainéant fait appel
      Canvas.MoveTo(Sg.x1, Sg.y1);  // au cablage matériel de la carte vidéo
      Canvas.LineTo(Sg.x1, Sg.y1)   // C'est rapide (plus rapide que l'UltraDIB
    End;                            // à partir d'une épaisseur de 8 mais sans le style) !
  End;
End;

procedure TDIBUltra.DirectLineTo (Sg : TLine); // Trace une ligne sans rien vérifier : Aie !
Begin
  Raise Exception.Create('NOT YET IMPLEMENTED');
End;

procedure TDIBUltra.Line;
Type JumpOn = (UU,OK,REJT,CUTV,CU0H,CT0H,CU1H,CT1H,CU0T,CU0B,CU0L,CU1T,CU1B,CU1R,CT0T,CT0B,CT1T,CT1B);
Const
  UUS  = 0; // ($UU|UU|UU|UU)
  Mask4bits0 : array[0..1] Of Byte = ($F0, $0F);
  Mask4bits1 : array[0..1] Of Byte = ($0F, $F0);
  Mask1bit0  : array[0..7] Of Byte = ($80, $40, $20, $10, $08, $04, $02, $01);
  Mask1bit1  : array[0..7] Of Byte = ($7F, $BF, $DF, $EF, $F7, $FB, $FD, $FE);

{$IFDEF NEVER_DEFINED}
  UU   :   UN-USED    : Adresse inutilisée, lève une exception si elle est l''objet de la sélection (BUG)
       :              :
  OK   :       OK     : Segment Accepté !
  REJT :    REJECT    : Segment Rejeté !
       :              :
  CUTV : CUT VERTICAL : Segment Coupé aux frontières Haut et Bas
       :              :
  CU0H : CUT HORIZONT.: Segment de pente négative, coupé aux frontières Droite et Gauche
  CT0H : CUT & TEST H : Segment de pente négative, coupé puis Testé aux frontières Verticales
       :              :
  CU1H : CUT HORIZONT.: Segment de pente positive, coupé aux frontières Droite et Gauche
  CT1H : CUT & TEST H : Segment de pente positive, coupé puis Testé aux frontières Verticales
       :              :
  CU0T : CUT TOP      : Segment Coupé au point 0, à la frontière Top
  CU1T : CUT TOP      : Segment Coupé au point 1, à la frontière Top
  CU0B : CUT BOTTOM   : Segment Coupé au point 0, à la frontière Bottom
  CU1B : CUT BOTTOM   : Segment Coupé au point 1, à la frontière Bottom
  CU0R : CUT RIGHT    : Segment Coupé au point 0, à la frontière Right
  CU1R : CUT RIGHT    : Segment Coupé au point 1, à la frontière Right
  CU0L : CUT LEFT     : Segment Coupé au point 0, à la frontière Left
  CU1L : CUT LEFT     : Segment Coupé au point 1, à la frontière Left
       :              :
  CT0T : CUT & TEST T : Segment Coupé au point 0, puis Testé à la frontière Top
  CT1T : CUT & TEST T : Segment Coupé au point 1, puis Testé à la frontière Top
  CT0B : CUT & TEST B : Segment Coupé au point 0, puis Testé à la frontière Bottom
  CT1B : CUT & TEST B : Segment Coupé au point 1, puis Testé à la frontière Bottom
{$ENDIF}

Var
//****************** VARIABLES ASM DE SAUVEGARDE ************************
  {$IFDEF ASM_IMPLEMENTATION}
  EBX       : LongInt;
  EDI       : LongInt;
  ESI       : LongInt;
  Resl      : Integer;
  PMode     : Integer;
  TrNotLast : Boolean;
  Coul      : Integer;
  CoulTmp   : Integer;
  Masque    : LongInt;
  {$ENDIF}
//****************** VARIABLES DE LA ROUTINE DE CLIPPING ****************

  Seg     : TLine;      // Le segment en cours de fenêtrage
  Clp     : TRect;      // Cette région de clipping
  CanDraw : Boolean;    // Le résultat est-il traçable ?
  Temp    : LongInt;    // Zone Tampon pour swapper les x1,y2 avec les x2,y2
  {$IFDEF DEBUG}
  InputSeg: TLine;
  {$ENDIF}

//****************** VARIABLES DE LA ROUTINE DE TRACAGE ****************

  PasX, PasY       : Integer;  // +1 ou -1 suivant le signe de Seg.dx et Seg.dy
  x, y, dx, dy     : Integer;  // dx/y largeur de la ligne Horizontale ou Verticale à tracer ; n : saut de ligne (H. ou V.)
  Pente, Pt        : integer;  // Optimisation en utilisant des entiers
  AdXPlus, AdYPlus : Integer;  // Quantité à ajouter pour progresser dans l'axe des X / Y dans la DIB
  {$IFNDEF ASM_IMPLEMENTATION}
  Courant         : Integer;
  {$ENDIF}

//****************** LEVEE D'EXCEPTION *********************************

  Procedure InternalError;
  Begin Raise DIB_ERROR.Create(DIBErr2) End;

//****************** INITIALISATION DE L'ADRESSE ************

  Procedure IniAdr; // Initialisation des adresses DIB
  Begin Case DIBResol Of
    DUpf1  : ;  // Not Yet Implemented
    DUpf4  : Begin Pt := Seg.y1*DIBWidth_b      +Seg.x1 div 2;AdYPlus := PasY * DIBWidth_b;       AdXPlus :=   PasX End;
    DUpf8  : Begin Pt := Seg.y1*DIBWidth_b      +Seg.x1;      AdYPlus := PasY * DIBWidth_b;       AdXPlus :=   PasX End;
    DUpf15,  // L'écriture d'un pixel à la résolution 15 ou 16 est équivalente
    DUpf16 : Begin Pt := Seg.y1*DIBHalfWidth    +Seg.x1;      AdYPlus := PasY * DIBHalfWidth;     AdXPlus :=   PasX End;
    DUpf24 : Begin Pt := Seg.y1*DIBWidth_b      +Seg.x1*3;    AdYPlus := PasY * DIBWidth_b;       AdXPlus := 3*PasX End;
    DUpf32 : Begin Pt := Seg.y1*DIBWidth_b div 2+Seg.x1;      AdYPlus := PasY * DIBWidth_b div 2; AdXPlus :=   PasX End;
  End End;

//****************** TRACAGE DE LA LIGNE HORIZONTALE ************

  Procedure HLine; // Solution intermédiaire à une implémentation ASM
{  var
    MODdx : Integer;
    Tmp   : Byte;}
  Begin Case DIBResol Of
    DUpf1          : ; // Not Yet Implemented
    DUpf4          : {Begin Repeat MODdx := Seg.x1 AND 1;
                       If PlotON Then Begin
                         Tmp := PxlB(DIBBits^)[Pt] AND Mask4bits1[MODdx];
                         PxlB(DIBBits^)[Pt] := CoulB AND Mask4bits0[MODdx] OR Tmp End;
                       Inc(Pt,AdXPlus AND MODdx); Dec(dx, PasX); Inc(Seg.x1, PasX) Until (dx=0);//(Pt=Fin)
                       Inc(Pt,AdYPlus) End };
    DUpf8          : Begin Repeat If PlotON Then PxlB(DIBAdr^)[Pt] := PCoulB; Inc(Pt,AdXPlus); Dec(dx, PasX) Until (dx=0);//(Pt=Fin)
                       Inc(Pt,AdYPlus) End;
    DUpf15, DUpf16 : Begin Repeat If PlotON Then PxlW(DIBAdr^)[Pt] := PCoulW; Inc(Pt,AdXPlus); Dec(dx, PasX) Until (dx=0);//(Pt=Fin)
                       Inc(Pt,AdYPlus) End;
    DUpf24         : Begin Repeat
                       If PlotON Then Begin PxlB(DIBAdr^)[Pt+0]:=PCoulB;PxlB(DIBAdr^)[Pt+1]:=PCoulV;PxlB(DIBAdr^)[Pt+2]:=PCoulR End;
                       Inc(Pt,AdXPlus); Dec(dx, PasX) Until (dx=0);
                       Inc(Pt,AdYPlus)
                     End;
    DUpf32         : Begin Repeat If PlotON Then PxlL(DIBAdr^)[Pt] := PCoulL; Inc(Pt,AdXPlus); Dec(dx, PasX) Until (dx=0);//(Pt=Fin)
                        Inc(Pt,AdYPlus) End;
  End End;

//****************** TRACAGE DE LA LIGNE VERTICALE ************

  Procedure VLine; // Solution en Pascal (lent)
  Begin Case DIBResol Of
    DUpf1          : ; // Not Yet Implemented
    DUpf4          : ;
    DUpf8          : Begin Repeat If PlotON Then PxlB(DIBAdr^)[Pt] := PCoulB; Inc(Pt,AdYPlus); Dec(dy,PasY) Until (dy=0);
                       Inc(Pt,AdXPlus) End;
    DUpf15, DUpf16 : Begin Repeat If PlotON Then PxlW(DIBAdr^)[Pt] := PCoulW; Inc(Pt,AdYPlus); Dec(dy,PasY) Until (dy=0);
                       Inc(Pt,AdXPlus) End;
    DUpf24         : Begin Repeat
                       If PlotON Then Begin PxlB(DIBAdr^)[Pt+0]:=PCoulB;PxlB(DIBAdr^)[Pt+1]:=PCoulV;PxlB(DIBAdr^)[Pt+2]:=PCoulR End;
                       Inc(Pt,AdYPlus); Dec(dy, PasY) Until (dy=0);
                       Inc(Pt,AdXPlus)
                     End;
    DUpf32         : Begin Repeat If PlotON Then PxlL(DIBAdr^)[Pt] := PCoulL; Inc(Pt,AdYPlus); Dec(dy,PasY) Until (dy=0);
                       Inc(Pt,AdXPlus) End;
  End End;

//****************** TRACAGE DE LA LIGNE DIAGONALE ************

  Procedure DIAGOLine;
  Begin Case DIBResol Of
   DUpf1, DUpf4   : ; // Not Yet Implemented
   DUpf8          : Repeat If PlotON Then PxlB(DIBAdr^)[Pt] := PCoulB; Inc(Pt,AdXPlus); Dec(dx,PasX) Until (dx=0);
   DUpf15, DUpf16 : Repeat If PlotON Then PxlW(DIBAdr^)[Pt] := PCoulW; Inc(Pt,AdXPlus); Dec(dx,PasX) Until (dx=0);
   DUpf24         : Repeat If PlotON Then Begin PxlB(DIBAdr^)[Pt+0]:=PCoulB;PxlB(DIBAdr^)[Pt+1]:=PCoulV;PxlB(DIBAdr^)[Pt+2]:=PCoulR End;
                      Inc(Pt,AdXPlus); Dec(dx,PasX)
                    Until (dx=0);
   DUpf32         : Repeat If PlotON Then PxlL(DIBAdr^)[Pt] := PCoulL; Inc(Pt,AdXPlus); Dec(dx,PasX) Until (dx=0);
  End End;

//****************** IMPLEMENTATION DU CLIPPING ************
Begin
  Seg.x1 := Sg.x1;
  Seg.y1 := Sg.y1;
  Seg.x2 := Sg.x2;
  Seg.y2 := Sg.y2;
  PasX   := 1;
  If (Seg.y1>Seg.y2) Then PasY := -1 else PasY:= 1;
  If (Seg.x1>Seg.x2) Then   // Le segment prend une orientation de gauche à droite
  Begin                   //  ASM // Ce code parait plus rapide et pourtant... (le XCHG est très pénalisant)
    PasX    := -1;        //    NEG  PasX
    Temp    := Seg.x2;    //    MOV  EAX, I(Seg.x2)
    Seg.x2  := Seg.x1;    //    MOV  ECX, I(Seg.y2)
    Seg.x1  := Temp;      //    XCHG EAX, I(Seg.x1)
    Temp    := Seg.y2;    //    XCHG ECX, I(Seg.y1)
    Seg.y2  := Seg.y1;    //    MOV  I(Seg.x2), EAX
    Seg.y1  := Temp       //    MOV  I(Seg.y2), ECX
  End;                    //  End;
  CanDraw:= True;      // A priori, on devrait pouvoir tracer
  Clp    := ClpRect;   // Recopie en local : ie SP == Cache de 1er niveau
  {$IFDEF DEBUG}
  InputSeg:= Seg;
  {$ENDIF}
  ASM   // Et Zou, TURBO ON
  //******************************************************************************//
  //********      IMPLEMENTATION ASSEMBLEUR DE L'ALGORITHME MODIFIE DE     *******//
  //********                      COHEN - SUTHERLAND                       *******//
  //********                   ************************                    *******//
  //********  CETTE IMPLEMENTATION PERMET DONC LE CLIPPING DU BITMAP !     *******//
  //********  CETTE IMPLEMENTATION NE SUPPORTE PAS UNE EPAISSEUR > 1 PIXEL *******//
  //******************************************************************************//
  //
  //                      Bit[0]=Signe(X - Xmin)
  //
  //                      <-|--->
  //                       Xmin       Xmax
  //                        |          |
  //                 PLAN   |   PLAN   |    PLAN
  //        ^        1001   |   1000   |    1010
  // Bit[3] |               |          |
  //   =    -  Y  ----------+------(Max,Max)-------  Y
  // (Ymax  | Max           |          |            Max
  //   - Y) |        PLAN   |   PLAN   |    PLAN        ^
  //        V        0001   |   0000   |    0010        |
  //                        |          |             Y  |  Bit[2]
  //           Y  ------(Min,Min)------+----------- Min -    =
  //          Min           |          |                |  (Y -
  //                 PLAN   |   PLAN   |    PLAN        V    Ymin)
  //                 0101   |   0100   |    0110
  //                        |          |
  //                       Xmin       Xmax
  //                               <---|->
  //
  //                      Bit[1]=Signe(Xmax - X)
  //
  //  Nota : La DIB est une image chirale de cette représentation :
  //         le point Min,Min y est en haut à gauche et le point Max,Max y est en bas à droite !
  //

  @TestSegment:
    XOR  EAX, EAX  // AL va être utilisé pour les tests de la zone de clipping

    // Test du premier point. Résultat : AL = 0000 XXXX ; X = 1 ou 0 en fonction de la zone
    MOV EDX, Clp.Bottom    // Préchargement des tampons
    MOV ECX, &Seg.y1

    SUB EDX, ECX           // Temp = (YMax - Y)
    SHL EDX,1 ; RCL AL, 1  // Bit[3] = Signe(Temp)
    SUB ECX, Clp.Top       // Temp = (Y - YMin)
    SHL ECX,1 ; RCL AL, 1  // Bit[2] = Signe(Temp)

    MOV EDX, Clp.Right     // Préchargement des tampons
    MOV ECX, &Seg.x1

    SUB EDX, ECX           // Temp = (Xmax - X)
    SHL EDX,1 ; RCL AL, 1  // Bit[1] = Signe(Temp)
    SUB ECX, Clp.Left      // Temp = (X - Xmin)
    SHL ECX,1 ; RCL AL, 1  // Bit[0] = Signe(Temp)

    // Test du second point.  Résultat : AL = XXXX YYYY ; Y = 1 ou 0 en fonction de la zone
    MOV EDX, Clp.Bottom    // Préchargement des tampons
    MOV ECX, &Seg.y2

    SUB EDX, ECX           // Temp = (YMax - Y)
    SHL EDX,1 ; RCL AL, 1  // Bit[3] = Signe(Temp)
    SUB ECX, Clp.Top       // Temp = (Y - YMin)
    SHL ECX,1 ; RCL AL, 1  // Bit[2] = Signe(Temp)

    MOV EDX, Clp.Right     // Préchargement des tampons
    MOV ECX, &Seg.x2

    SUB EDX, ECX           // Temp = (Xmax - X)
    SHL EDX,1 ; RCL AL, 1  // Bit[1] = Signe(Temp)
    SUB ECX, Clp.Left      // Temp = (X - Xmin)
    SHL ECX,1 ; RCL AL, 1  // Bit[0] = Signe(Temp)

  // Pendant la double indirection, on calcule :
  //   Seg.dy := Seg.y2 - Seg.y1;
  //   Seg.dx := Seg.x2 - Seg.x1;
  // Cela supprime la dépendance de données entre les instructions
  // de l'indirection et évite les cycles de freeze du pipeline du
  // processeur (type Pentium et successeur x86)

    MOV ECX,    &Seg.y2   {Calcul de Seg.dy}
    LEA EAX,    [EAX*1 + @Table1]          // Double Indirection : premier niveau
    SUB ECX,    &Seg.y1   {Calcul de Seg.dy}
    MOVZX EAX,  BYTE PTR [EAX]             // Double Indirection : Récupération du N de On N Goto
    MOV &Seg.dy, ECX      {Calcul de Seg.dy}
    LEA EAX,    [EAX*4 + @Table2]          // Double Indirection : deuxième niveau
    MOV ECX,    &Seg.x2   {Calcul de Seg.dx}
    MOV EAX,    [EAX]                      // Prepare to JUMP
    SUB ECX,    &Seg.x1   {Calcul de Seg.dx}
    MOV &Seg.&dx,ECX      {Calcul de Seg.dx}
    JMP EAX                                // GO ! : On X Goto n1,n2,n3,n4,n5...

  @Table1:
  //////CODES  0000,0001,0010,0011,0100,0101,0110,0111,1000,1001,1010, & 1011,1100,1101,1110, 1111 {Point B}
   {0000:} DB   OK , UU ,CU1R, UU ,CU1B, UU ,CT1B, UU ,CU1T, UU ,CT1T; DD UUS ; DB UU
   {0001:} DB  CU0L,REJT,CUTV, UU ,CT1B,REJT,CT1B, UU ,CT1T,REJT,CT1T; DD UUS ; DB UU
   {0010:} DB   UU , UU ,REJT, UU , UU , UU ,REJT, UU ,CT1T, UU ,REJT; DD UUS ; DB UU
   {0011*} DB   UU , UU , UU , UU , UU , UU , UU , UU , UU , UU , UU ; DD UUS ; DB UU
   {0100:} DB  CU0B, UU ,CT0B, UU ,REJT, UU ,REJT, UU ,CU1H, UU ,CT1H; DD UUS ; DB UU
   {0101:} DB  CT0B,REJT,CT0B, UU ,REJT,REJT,REJT, UU ,CT1H,REJT,CT1H; DD UUS ; DB UU
   {0110:} DB   UU , UU ,REJT, UU , UU ,REJT,REJT, UU , UU , UU ,REJT; DD UUS ; DB UU
   {0111*} DB   UU , UU , UU , UU , UU , UU , UU , UU , UU , UU , UU ; DD UUS ; DB UU
   {1000:} DB  CU0T, UU ,CT0T, UU ,CU0H, UU ,CT0H, UU ,REJT, UU ,REJT; DD UUS ; DB UU
   {1001:} DB  CT0T,REJT,CT0T, UU ,CT0H,REJT,CT0H, UU ,REJT,REJT,REJT; DD UUS ; DB UU
   {1010:} DB   UU , UU ,REJT, UU , UU , UU ,REJT, UU , UU , UU ,REJT; DD UUS ; DB UU
   {Point A}

  @Table2: // D'après le Type
           // JumpOn = (UU,OK,REJT,CUTV,CUTH,CTEH,CU0T,CU0B,CU0L,CU1T,CU1B,CU1R,CT0T,CT0B,CT1T,CT1B);
           DD  InternalError // Erreur ! On lève une exception ...
           DD  @End  // OK
           DD  @REJT
           DD  @CUTV
           DD  @CU0H
           DD  @CT0H
           DD  @CU1H
           DD  @CT1H
           DD  @CU0T
           DD  @CU0B
           DD  @CU0L
           DD  @CU1T
           DD  @CU1B
           DD  @CU1R
           DD  @CT0T
           DD  @CT0B
           DD  @CT1T
           DD  @CT1B

  //***************************************************
  //*******  SOUS ROUTINES DE CALCUL  *****************
  //***************************************************

  {
    Function NewX(YLim : Word) : Word;
    Begin Segult := Seg.x1 + (Seg.dx * (YLim - Seg.y1)) div Seg.dy End;
  }
  @NewX: // FUNCTION (EAX : YLIM) : AX;
    SUB   EAX,   &Seg.y1
    IMUL  &Seg.&dx // Le compilo ASM sursaute en voyant dx
    IDIV  &Seg.dy
    ADD   EAX,   &Seg.x1
    RET

  {
    Function NewY(XLim : Word) : Word;
    Begin Segult := Seg.y1 + (Seg.dy * (XLim - Seg.x1)) div Seg.dx End;
  }
  @NewY: // FUNCTION (EAX : XLIM) : AX;
    SUB   EAX,   &Seg.x1
    IMUL  &Seg.&dy
    IDIV  &Seg.&dx
    ADD   EAX,   &Seg.y1
    RET

  //**************************************************
  //*******  TRAITEMENT DU ON n GOTO  ****************
  //**************************************************

  @REJT: // Rejet du segment
     MOV   CanDraw, False
     JMP   @End;

  @CT0H: // Découpe Horizontale puis ReTest d'un segment de pente négative
     MOV   EAX, Clp.Top
     MOV   &Seg.y2, EAX
     CALL  @NEWX
     MOV   &Seg.x2, EAX

     MOV   EAX, Clp.Bottom
     CALL  @NEWX
     MOV   &Seg.x1, EAX
     MOV   EAX, Clp.Bottom
     MOV   &Seg.y1, EAX
     // Le résultat est à retester :
     JMP  @TestSegment

  @CT1H: // Découpe Horizontale puis ReTest d'un segment de pente positive
     MOV   EAX, Clp.Bottom
     MOV   &Seg.y2, EAX
     CALL  @NEWX
     MOV   &Seg.x2, EAX

     MOV   EAX, Clp.Top
     CALL  @NEWX
     MOV   &Seg.x1, EAX
     MOV   EAX, Clp.Top
     MOV   &Seg.y1, EAX
     // Le résultat est à retester :
     JMP  @TestSegment

  @CT0T: // On remplace le point 0 => Seg.xy1 écrasés
     MOV   EAX, Clp.Bottom
     CALL  @NEWX
     MOV   &Seg.x1, EAX
     MOV   EAX, Clp.Bottom
     MOV   &Seg.y1, EAX
     // Le résultat est à retester :
     JMP  @TestSegment

  @CT1T: // On remplace le point 1 => Seg.xy2 écrasés
     MOV   EAX, Clp.Bottom
     MOV   &Seg.y2, EAX
     CALL  @NEWX
     MOV   &Seg.x2, EAX
     // Le résultat est à retester :
     JMP  @TestSegment

  @CT0B: // On remplace le point 0 => Seg.xy1 écrasés
     MOV   EAX, Clp.Top
     CALL  @NEWX
     MOV   &Seg.x1, EAX
     MOV   EAX, Clp.Top
     MOV   &Seg.y1, EAX
     // Le résultat est à retester :
     JMP  @TestSegment

  @CT1B: // On remplace le point 1 => Seg.xy2 écrasés
     MOV   EAX, Clp.Top
     MOV   &Seg.y2, EAX
     CALL  @NEWX
     MOV   &Seg.x2, EAX
     // Le résultat est à retester :
     JMP  @TestSegment

  @CUTV: // Découpe Verticale d'un segment
     MOV   EAX, Clp.Right
     MOV   &Seg.x2, EAX
     CALL  @NEWY
     MOV   &Seg.y2, EAX

     MOV   EAX, Clp.Left
     CALL  @NEWY
     MOV   &Seg.y1, EAX
     MOV   EAX, Clp.Left
     MOV   &Seg.x1, EAX

     JMP   @Computedxdy // Le Résultat est OK

  @CU0H: // Découpe Horizontale d'un segment de pente négative
     MOV   EAX, Clp.Top  // On ne touche pas à x1 et y1 tout d'abord
     MOV   &Seg.y2, EAX
     CALL  @NEWX
     MOV   &Seg.x2, EAX

     MOV   EAX, Clp.Bottom
     CALL  @NEWX
     MOV   &Seg.x1, EAX
     MOV   EAX, Clp.Bottom
     MOV   &Seg.y1, EAX

     JMP   @Computedxdy // Le Résultat est OK

  @CU1H: // Découpe Horizontale d'un segment de pente positive
     MOV   EAX, Clp.Bottom  // On ne touche pas à x1 et y1 tout d'abord
     MOV   &Seg.y2, EAX
     CALL  @NEWX
     MOV   &Seg.x2, EAX

     MOV   EAX, Clp.Top
     CALL  @NEWX
     MOV   &Seg.x1, EAX
     MOV   EAX, Clp.Top
     MOV   &Seg.y1, EAX

     JMP   @Computedxdy // Le Résultat est OK

  @CU0T: // On remplace le point 0 => Seg.xy1 écrasés
     MOV   EAX, Clp.Bottom
     CALL  @NEWX
     MOV   &Seg.x1, EAX
     MOV   EAX, Clp.Bottom
     MOV   &Seg.y1, EAX
     JMP   @Computedxdy // Le Résultat est OK

  @CU1T: // On remplace le point 1 => Seg.xy2 écrasés
     MOV   EAX, Clp.Bottom
     MOV   &Seg.y2, EAX
     CALL  @NEWX
     MOV   &Seg.x2, EAX
     JMP   @Computedxdy // Le Résultat est OK

  @CU0B: // On remplace le point 0 => Seg.xy1 écrasés
     MOV   EAX, Clp.Top
     CALL  @NEWX
     MOV   &Seg.x1, EAX
     MOV   EAX, Clp.Top
     MOV   &Seg.y1, EAX
     JMP   @Computedxdy // Le Résultat est OK

  @CU1B: // On remplace le point 1 => Seg.xy2 écrasés
     MOV   EAX, Clp.Top
     MOV   &Seg.y2, EAX
     CALL  @NEWX
     MOV   &Seg.x2, EAX
     JMP   @Computedxdy // Le Résultat est OK

  @CU1R: // On remplace le point 1 => Seg.xy2 écrasés
     MOV   EAX, Clp.Right
     MOV   &Seg.x2, EAX
     CALL  @NEWY
     MOV   &Seg.y2, EAX
     JMP   @Computedxdy // Le Résultat est OK

  @CU0L: // On remplace le point 0 => Seg.xy1 écrasés
     MOV   EAX, Clp.Left
     CALL  @NEWY
     MOV   &Seg.y1, EAX
     MOV   EAX, Clp.Left
     MOV   &Seg.x1, EAX     // Le Résultat est OK
//     JMP   @Computedxdy // Pas la peine de Jumper, c'est l'octet suivant

  @Computedxdy:{Suppression des dépendances de données par algorithme interlacé}
    MOV EAX,    &Seg.y2   {Calcul de Seg.dy}
    MOV ECX,    &Seg.x2   {Calcul de Seg.dx}
    SUB EAX,    &Seg.y1   {Calcul de Seg.dy}
    SUB ECX,    &Seg.x1   {Calcul de Seg.dx}
    MOV &Seg.dy, EAX      {Calcul de Seg.dy}
    MOV &Seg.&dx,ECX      {Calcul de Seg.dx}
    // On poursuit gentiment vers @End :

  @End: // Fin de la routine ASM de clipping
  End;
  If Not CanDraw Then Exit; // Le segment a été éliminé

{$IFDEF DEBUG}
// Vérification du bon fonctionnement du clipping : MODE DEBUG !
  If (Seg.x2<Seg.x1  )OR
     (Seg.x1<Clp.Left)OR(Seg.x1>Clp.Right )OR
     (Seg.y1<Clp.Top )OR(Seg.y1>Clp.Bottom)OR
     (Seg.x2<Clp.Left)OR(Seg.x2>Clp.Right )OR
     (Seg.y2<Clp.Top )OR(Seg.y2>Clp.Bottom)Then
    Begin
        MessageDlg('Erreur de clipping : '#13+
                    'Segment en entrée : '+IntToStr(InputSeg.x1)+','+IntToStr(InputSeg.y1)+'/'+IntToStr(InputSeg.x2)+','+IntToStr(InputSeg.y2)+#13+
                    'Segment Clippé    : '+IntToStr(Seg.x1)+','+IntToStr(Seg.y1)+'/'+IntToStr(Seg.x2)+','+IntToStr(Seg.y2)+'.',mtError , [mbOK] , 0);
        Exit;
    End;
{$ENDIF}

  //********************************************************************************//
  //******  IMPLEMENTATION ASSEMBLEUR D'UN ALGORITHME DE TRACE DE LIGNES       *****//
  //******                ASSEMBLY LANGAGE LINETO IMPLEMENTATION               *****//
  //******                                                                     *****//
  //******  ISSU DE RECHERCHES PERSONNELLES... (SANS RAPPORT AVEC BRESENHEIM)  *****//
  //******  THIS IS NOT A BRESENHEIM IMPLEMENTATION RATHER MY OWN WORKS !      *****//
  //******                   ************************                          *****//
  //******  CETTE IMPLEMENTATION SUPPORTE DIFFERENTS UN STYLES DE TRAIT        *****//
  //******  CETTE IMPLEMENTATION SUPPORTE DIFFERENTS UN MODE DE STYLO          *****//
  //******  CETTE IMPLEMENTATION PEUT EMULER LE COMPORTEMENT DU GDI            *****//
  //******  COMME DIRAIT MANDRAKESOFT : CETTE IMPLEMENTATION VOUS VA BIEN !    *****//
  //********************************************************************************//
  //
  // Le clipping est terminé, passons à l'affichage du segment
  // Présemption à l'entrée de la routine :
  // xy est calculé correctement pour tous ses champs
  // ie: x1 <= x2
  //     dx = x2 - x1
  //     dy = y2 - y1
  //     dx >= 0
  //
  // Pour permettre un tracé de ligne en mode pointillé,
  // on reprend l'ordre initial d'un x1 qui peut être supérieur à x2.
  //
  // Puis on sépare le traitement en 3 catégories :
  //
  // ¤ dx>|dy| : ligne moins pentue qu'une oblique à 45°
  // ¤ dx<|dy| : ligne plus pentue qu'une oblique à 45°
  // ¤ dx=|dy| : [dx=0 : Plot d'un point],[dx>0 : ligne à 45°] (Optimisation)

  If (PasX < 0) Then   // Retournement de xy pour restaurer l'état initial
  Begin                   //  ASM // Ce code parait plus rapide et pourtant... (le XCHG est très pénalisant)
    Seg.dx  := -Seg.dx;   //    NEG  Seg.&dx
    Seg.dy  := -Seg.dy;   //    NEG  Seg.dy
    Temp    := Seg.x2;    //    MOV  EAX, I(Seg.x2)
    Seg.x2  := Seg.x1;    //    MOV  ECX, I(Seg.y2)
    Seg.x1  := Temp;      //    XCHG EAX, I(Seg.x1)
    Temp    := Seg.y2;    //    XCHG ECX, I(Seg.y1)
    Seg.y2  := Seg.y1;    //    MOV  I(Seg.x2), EAX
    Seg.y1  := Temp       //    MOV  I(Seg.y2), ECX
  End;                    //  End;
  IniAdr; // Initialisation de l'adresse d'ecriture en DIB (commun aux 2 implémentation)
  {$IFDEF ASM_IMPLEMENTATION}
  // Récupération des variables champs Self. ...
  Resl      := Ord(DIBResol); // Utile par la suite en asm
  PMode     := 7 * Ord(Mode);
  TrNotLast := NotLast;
  Masque    := Self.Mask;
  AdXPlus   := I(DIBAdr);
  Case DIBResol Of
    DUpf1,  DUpf4,
    DUpf8          : Begin Coul := Self.PCoulB End;
    DUpf15, DUpf16 : Begin Coul := Self.PCoulW End;
    DUpf24, DUpf32 : Begin Coul := Self.PCoulL End;
  End;
  {$ENDIF}

  {$IFDEF ASM_IMPLEMENTATION}
  // Convention routine ASM :
  // EAX en accumulateur
  // EBX : (détourné) = PasX Si HLine ; = PasY Si VLine
  // ECX : Compteur des lignes horizontales ou verticales
  // EDX : Valeur Courante, non arrondie : Courant
  // ESI : (détourné) Adresse de la Sous-Routine de tracé HLine ou VLine
  // EDI : (détourné) Adresse mémoire dans la DIB du point à placer
  // ESP : (détourné) Pente
  // EBP : (détourné)
  ASM
    MOV &EBX, EBX // Sauvegarde de EBX
    MOV &EDI, EDI // Sauvegarde de EBX
    MOV &ESI, ESI // Sauvegarde de ESP

    MOV ECX, PasX
    MOV EBX, PasY
    ADD &Seg.&dx, ECX  //  Inc(Seg.dx,PasX);
    ADD &Seg.dy,  EBX  //  Inc(Seg.dy,PasY);

    CALL  @IniAdr    // IniXAdr; => EDI Initialisé

    MOV EAX, &Seg.&dx
    BT  ECX, 31      // PasX négatif ?
    JNC @DXPOS
    NEG EAX
  @DXPOS:
    BT  EBX, 31      // PasY négatif ?
    JC  @ADD
    SUB EAX, &Seg.dy
    JMP @SUITEPENTE
  @ADD:
    ADD EAX, &Seg.dy
  @SUITEPENTE:
    // Dans AX : (Seg.dx*PasX)-(Seg.dy*PasY);
    //

  JZ  @PENTEOBLIQUE // droite à 45 degrés
  JS  @PENTEVERT    // droite plutôt verticale
  JMP @PENTEHORZ    // droite plutôt horizontale

  @PENTEHORZ: // Droite orientée horizontale
  // Rappel Convention routine ASM :
  // EAX : Accumulateur , Zone tampon
  // EBX : (détourné) = PasX Si HLine ; = PasY Si VLine
  // ECX : Compteur des lignes horizontales ou verticales
  // EDX : Valeur Courante, non arrondie : Courant
  // ESI : (détourné) Adresse de la Sous-Routine de tracé HLine ou VLine
  // EDI : (détourné) Adresse mémoire dans la DIB du point à placer
  // ESP : NON détourné  => Debug Possible...
  // EBP : NON détourné
  // Pour l'instant :
  // ECX = PasX et EBX = PasY

    // Pente   :=(Seg.dx * $10000) div Seg.dy * PasY;
    MOV   EAX, &Seg.&dx
    SHL   EAX, 16
    BT    EBX, 31 // PasY négatif ?
    JNC   @SEGDYPOS
    NEG   EAX
  @SEGDYPOS:
    CDQ
    IDIV  &Seg.dy // Ecrasement de PasX dans ECX
    MOV   Pente, EAX  // Sauvegarde de la pente

  // Il reste PasY dans EBX
  // Courant := (Seg.x1 * $10000) + $8000 - PasX * $10000;
    MOV   EDX, &Seg.x1
    SUB   EDX, PasX
    SHL   EDX, 16
    ADD   EDX, $8000  // EDX = Courant ; A Jour

    MOV   EAX, &Seg.x1 //  x := Seg.x1 - PasX;
    SUB   EAX, PasX
    MOV   x  , EAX

  // Sélection de la sous-routine de tracé
    MOV   EAX, Resl
    ADD   EAX, PMode
    LEA   EAX, DWORD PTR [ EAX*4 + @HRZTable ]
    MOV   ESI, [ EAX ]

  // Boucle While - End
  @HORZWHILE:
    SUB   &Seg.dy, EBX // Dec(Seg.dy, PasY);  // Incrementation du compteur de boucle : une ligne de +
    JZ    @HORZWEND   // Reste-il des lignes ?
    ADD   EDX, Pente  // Inc(Courant,Pente); // Mise A Jour de la position courante en double précision
    MOV   EAX, x      // dx := x;
    MOV   ECX, EDX    // x := Courant shr 16;
    SAR   ECX, 16
    MOV   x,   ECX
    SUB   ECX, EAX    // dx := x - dx;
    CALL  ESI         // Appel de la sous routine HLINE ;
    JMP   @HORZWHILE
    JMP @EXIT

  @HORZWEND:
    MOV   ECX, &Seg.x2     // dx := Seg.x2 - x;       // Dernière ligne horizontale, ecourtée ou non d'un point
    SUB   ECX, x
    CMP   TrNotLast, False // If NotLast Then Dec(dx,PasX);
    JZ    @LASTHORZLINE
    SUB   ECX, PasX
    JZ    @EXIT            // If (dx<>0) Then HLine;
  @LASTHORZLINE:
    CALL ESI // Appel de la sous routine HLINE
    JMP  @EXIT

  @HRZTable: // TDUPixelFormat = (DUpf1, DUpf4, DUpf8, DUpf15, DUpf16, DUpf24, DUpf32, DUpfCustom);
    // COPY PEN TO PIXEL :
    DD  @LINEHORZT01BITSCOPYPEN // DUpf1   // NOT YET SUPPORTED
    DD  @LINEHORZT04BITSCOPYPEN // DUpf4   // NOT YET SUPPORTED
    DD  @LINEHORZT08BITSCOPYPEN // DUpf8
    DD  @LINEHORZT16BITSCOPYPEN // DUpf15
    DD  @LINEHORZT16BITSCOPYPEN // DUpf16
    DD  @LINEHORZT24BITSCOPYPEN // DUpf24
    DD  @LINEHORZT32BITSCOPYPEN // DUpf32
    // NOT PIXEL :
    DD  @LINEHORZT01BITSNOT     // DUpf1   // NOT YET SUPPORTED
    DD  @LINEHORZT04BITSNOT     // DUpf4   // NOT YET SUPPORTED
    DD  @LINEHORZT08BITSNOT     // DUpf8
    DD  @LINEHORZT16BITSNOT     // DUpf15
    DD  @LINEHORZT16BITSNOT     // DUpf16
    DD  @LINEHORZT24BITSNOT     // DUpf24
    DD  @LINEHORZT32BITSNOT     // DUpf32
    // PEN AND PIXELS :
    DD  @LINEHORZT01BITSANDPEN  // DUpf1   // NOT YET SUPPORTED
    DD  @LINEHORZT04BITSANDPEN  // DUpf4   // NOT YET SUPPORTED
    DD  @LINEHORZT08BITSANDPEN  // DUpf8
    DD  @LINEHORZT16BITSANDPEN  // DUpf15
    DD  @LINEHORZT16BITSANDPEN  // DUpf16
    DD  @LINEHORZT24BITSANDPEN  // DUpf24
    DD  @LINEHORZT32BITSANDPEN  // DUpf32
    // PEN OR PIXELS :
    DD  @LINEHORZT01BITSORPEN   // DUpf1   // NOT YET SUPPORTED
    DD  @LINEHORZT04BITSORPEN   // DUpf4   // NOT YET SUPPORTED
    DD  @LINEHORZT08BITSORPEN   // DUpf8
    DD  @LINEHORZT16BITSORPEN   // DUpf15
    DD  @LINEHORZT16BITSORPEN   // DUpf16
    DD  @LINEHORZT24BITSORPEN   // DUpf24
    DD  @LINEHORZT32BITSORPEN   // DUpf32
    // PEN XOR PIXELS :
    DD  @LINEHORZT01BITSXORPEN  // DUpf1   // NOT YET SUPPORTED
    DD  @LINEHORZT04BITSXORPEN  // DUpf4   // NOT YET SUPPORTED
    DD  @LINEHORZT08BITSXORPEN  // DUpf8
    DD  @LINEHORZT16BITSXORPEN  // DUpf15
    DD  @LINEHORZT16BITSXORPEN  // DUpf16
    DD  @LINEHORZT24BITSXORPEN  // DUpf24
    DD  @LINEHORZT32BITSXORPEN  // DUpf32
    // PEN ALPHA PIXELS :
    DD  @LINEHORZT01BITSCOPYPEN  // DUpf1  // ALPHA IS NOT SUPPORTED FOR LOW RESOLUTION
    DD  @LINEHORZT04BITSCOPYPEN  // DUpf4  // ALPHA IS NOT SUPPORTED FOR LOW RESOLUTION
    DD  @LINEHORZT08BITSCOPYPEN  // DUpf8  // ALPHA IS NOT SUPPORTED FOR LOW RESOLUTION
    DD  @LINEHORZT16BITSALPHAPEN // DUpf15 // NOT YET SUPPORTED
    DD  @LINEHORZT16BITSALPHAPEN // DUpf16 // NOT YET SUPPORTED
    DD  @LINEHORZT24BITSALPHAPEN // DUpf24 // NOT YET SUPPORTED
    DD  @LINEHORZT32BITSALPHAPEN // DUpf32 // NOT YET SUPPORTED
    // USER CALL BACK :
    DD  @LINEHORZT01BITSUSER    // DUpf1   // NOT YET SUPPORTED
    DD  @LINEHORZT04BITSUSER    // DUpf4   // NOT YET SUPPORTED
    DD  @LINEHORZT08BITSUSER    // DUpf8   // NOT YET SUPPORTED
    DD  @LINEHORZT16BITSUSER    // DUpf15  // NOT YET SUPPORTED
    DD  @LINEHORZT16BITSUSER    // DUpf16  // NOT YET SUPPORTED
    DD  @LINEHORZT24BITSUSER    // DUpf24  // NOT YET SUPPORTED
    DD  @LINEHORZT32BITSUSER    // DUpf32  // NOT YET SUPPORTED

  @PENTEVERT: // Droite orientée horizontale
  // Rappel Convention routine ASM :
  // EAX : Accumulateur , Zone tampon
  // EBX : (détourné) = PasX Si HLine ; = PasY Si VLine
  // ECX : Compteur des lignes horizontales ou verticales
  // EDX : Valeur Courante, non arrondie : Courant
  // ESI : (détourné) Adresse de la Sous-Routine de tracé HLine ou VLine
  // EDI : (détourné) Adresse mémoire dans la DIB du point à placer
  // ESP : NON détourné  => Debug Possible...
  // EBP : NON détourné
  // Pour l'instant :
    MOV   EBX, ECX
  // ECX,EBX = PasX

    //Pente   :=(Seg.dy * $10000) div Seg.dx * PasX;
    MOV   EAX,  &Seg.dy
    SHL   EAX, 16
    BT    EBX, 31 // PasX négatif ?
    JNC   @SEGDXPOS
    NEG   EAX
  @SEGDXPOS:
    CDQ
    IDIV  &Seg.&dx
    MOV   Pente, EAX  // Sauvegarde de la pente

  // Courant := (Seg.y1 - PasY) * $10000 + $8000;
    MOV   EDX, &Seg.y1
    SUB   EDX, PasY
    SHL   EDX, 16
    ADD   EDX, $8000  // EDX = Courant ; A Jour

    MOV   EAX, &Seg.y1 //  y := Seg.y1 - PasY;
    SUB   EAX, PasY
    MOV   y  , EAX

  // Sélection de la sous-routine de tracé
    MOV   EAX, Resl
    ADD   EAX, PMode
    LEA   EAX, DWORD PTR [ EAX*4 + @VERTable ]
    MOV   ESI, [ EAX ]

  // Boucle While - End
  @VERTWHILE:
    SUB   &Seg.&dx, EBX // Dec(Seg.dx, PasX);  // Incrementation du compteur de boucle : une ligne de +
    JZ    @VERTWEND   // Reste-il des lignes ?
    ADD   EDX, Pente  // Inc(Courant,Pente); // Mise A Jour de la position courante en double précision
    MOV   EAX, y      // dy := y;
    MOV   ECX, EDX    // y := Courant shr 16;
    SAR   ECX, 16
    MOV   y,   ECX
    SUB   ECX, EAX    // dy := y - dy;
    CALL  ESI         // Appel de la sous routine HLINE ;
    JMP   @VERTWHILE
  @VERTWEND:
    MOV   ECX, &Seg.y2      // dy := Seg.y2 - y; // Dernière ligne verticale, ecourtée ou non d'un point
    SUB   ECX, y
    CMP   TrNotLast, False // If NotLast Then Dec(dx,PasX);
    JZ    @LASTVERTLINE
    SUB   ECX, PasY
    JZ    @EXIT            // If (dy<>0) Then HLine;
  @LASTVERTLINE:
    CALL ESI // Appel de la sous routine HLINE
    JMP  @EXIT

  @VERTable: // TDUPixelFormat = (DUpf1, DUpf4, DUpf8, DUpf15, DUpf16, DUpf24, DUpf32, DUpfCustom);
    // COPY PEN TO PIXEL :
    DD  @LINEVERT01BITSCOPYPEN // DUpf1   // NOT YET SUPPORTED
    DD  @LINEVERT04BITSCOPYPEN // DUpf4   // NOT YET SUPPORTED
    DD  @LINEVERT08BITSCOPYPEN // DUpf8
    DD  @LINEVERT16BITSCOPYPEN // DUpf15
    DD  @LINEVERT16BITSCOPYPEN // DUpf16
    DD  @LINEVERT24BITSCOPYPEN // DUpf24
    DD  @LINEVERT32BITSCOPYPEN // DUpf32
    // NOT PIXEL :
    DD  @LINEVERT01BITSNOT     // DUpf1   // NOT YET SUPPORTED
    DD  @LINEVERT04BITSNOT     // DUpf4   // NOT YET SUPPORTED
    DD  @LINEVERT08BITSNOT     // DUpf8
    DD  @LINEVERT16BITSNOT     // DUpf15
    DD  @LINEVERT16BITSNOT     // DUpf16
    DD  @LINEVERT24BITSNOT     // DUpf24
    DD  @LINEVERT32BITSNOT     // DUpf32
    // PEN AND PIXELS :
    DD  @LINEVERT01BITSANDPEN  // DUpf1   // NOT YET SUPPORTED
    DD  @LINEVERT04BITSANDPEN  // DUpf4   // NOT YET SUPPORTED
    DD  @LINEVERT08BITSANDPEN  // DUpf8
    DD  @LINEVERT16BITSANDPEN  // DUpf15
    DD  @LINEVERT16BITSANDPEN  // DUpf16
    DD  @LINEVERT24BITSANDPEN  // DUpf24
    DD  @LINEVERT32BITSANDPEN  // DUpf32
    // PEN OR PIXELS :
    DD  @LINEVERT01BITSORPEN   // DUpf1   // NOT YET SUPPORTED
    DD  @LINEVERT04BITSORPEN   // DUpf4   // NOT YET SUPPORTED
    DD  @LINEVERT08BITSORPEN   // DUpf8
    DD  @LINEVERT16BITSORPEN   // DUpf15
    DD  @LINEVERT16BITSORPEN   // DUpf16
    DD  @LINEVERT24BITSORPEN   // DUpf24
    DD  @LINEVERT32BITSORPEN   // DUpf32
    // PEN XOR PIXELS :
    DD  @LINEVERT01BITSXORPEN  // DUpf1   // NOT YET SUPPORTED
    DD  @LINEVERT04BITSXORPEN  // DUpf4   // NOT YET SUPPORTED
    DD  @LINEVERT08BITSXORPEN  // DUpf8
    DD  @LINEVERT16BITSXORPEN  // DUpf15
    DD  @LINEVERT16BITSXORPEN  // DUpf16
    DD  @LINEVERT24BITSXORPEN  // DUpf24
    DD  @LINEVERT32BITSXORPEN  // DUpf32
    // PEN ALPHA PIXELS :
    DD  @LINEVERT01BITSCOPYPEN  // DUpf1  // ALPHA IS NOT SUPPORTED FOR LOW RESOLUTION
    DD  @LINEVERT04BITSCOPYPEN  // DUpf4  // ALPHA IS NOT SUPPORTED FOR LOW RESOLUTION
    DD  @LINEVERT08BITSCOPYPEN  // DUpf8  // ALPHA IS NOT SUPPORTED FOR LOW RESOLUTION
    DD  @LINEVERT16BITSALPHAPEN // DUpf15 // NOT YET SUPPORTED
    DD  @LINEVERT16BITSALPHAPEN // DUpf16 // NOT YET SUPPORTED
    DD  @LINEVERT24BITSALPHAPEN // DUpf24 // NOT YET SUPPORTED
    DD  @LINEVERT32BITSALPHAPEN // DUpf32 // NOT YET SUPPORTED
    // USER CALL BACK :
    DD  @LINEVERT01BITSUSER    // DUpf1   // NOT YET SUPPORTED
    DD  @LINEVERT04BITSUSER    // DUpf4   // NOT YET SUPPORTED
    DD  @LINEVERT08BITSUSER    // DUpf8   // NOT YET SUPPORTED
    DD  @LINEVERT16BITSUSER    // DUpf15  // NOT YET SUPPORTED
    DD  @LINEVERT16BITSUSER    // DUpf16  // NOT YET SUPPORTED
    DD  @LINEVERT24BITSUSER    // DUpf24  // NOT YET SUPPORTED
    DD  @LINEVERT32BITSUSER    // DUpf32  // NOT YET SUPPORTED
  @PENTEOBLIQUE: // Droite oblique
  // Convention particulière pour la pente oblique :
  // Optimisation :
  //   (Courant n'existe plus => EDX est libre)
  //   EDX <= AdrXPlus + AdrYPlus (sauf pour la résolution 24 bits)
  //   EBX <= PasX
  // Le reste sans modif:
  //
  // Rappel Convention routine ASM :
  // EAX : Accumulateur , Zone tampon (utilisé dans OBLLINE pour la couleur)
  // ECX : Compteur des lignes horizontales ou verticales
  // ESI : (détourné) Adresse de la Sous-Routine de tracé HLine ou VLine
  // EDI : (détourné) Adresse mémoire dans la DIB du point à placer
  // ESP : NON détourné  => Debug Possible...
  // EBP : NON détourné
    MOV   EBX, ECX  // ECX,EBX = PasX

  // Sélection de la sous-routine de tracé
    MOV   EAX, Resl
    LEA   EAX, DWORD PTR [ EAX*4 + @DIAGTable ]
    MOV   ESI, [ EAX ]
  // Préparation
    MOV   ECX, &Seg.&dx     // dx      := Seg.dx;
    CMP   TrNotLast, False // If NotLast Then Dec(dx,PasX);
    JZ    @OBLLINE
    SUB   ECX, PasX
    JZ    @EXIT            // If (dx<>0) Then DIAGOLine;
  @OBLLINE:
    MOV   EAX, AdYPlus     // AdXPlus := AdXPlus + AdYPlus;
    ADD   AdXPlus, EAX
    CALL ESI               // Appel de la sous routine @DIAGOLINE
    JMP  @EXIT

  @DIAGTable: // TDUPixelFormat = (DUpf1, DUpf4, DUpf8, DUpf15, DUpf16, DUpf24, DUpf32, DUpfCustom);

    // COPY PEN TO PIXEL :
    DD  @LINEOBL01BITSCOPYPEN // DUpf1   // NOT YET SUPPORTED
    DD  @LINEOBL04BITSCOPYPEN // DUpf4   // NOT YET SUPPORTED
    DD  @LINEOBL08BITSCOPYPEN // DUpf8
    DD  @LINEOBL16BITSCOPYPEN // DUpf15
    DD  @LINEOBL16BITSCOPYPEN // DUpf16
    DD  @LINEOBL24BITSCOPYPEN // DUpf24
    DD  @LINEOBL32BITSCOPYPEN // DUpf32
    // NOT PIXEL :
    DD  @LINEOBL01BITSNOT     // DUpf1   // NOT YET SUPPORTED
    DD  @LINEOBL04BITSNOT     // DUpf4   // NOT YET SUPPORTED
    DD  @LINEOBL08BITSNOT     // DUpf8
    DD  @LINEOBL16BITSNOT     // DUpf15
    DD  @LINEOBL16BITSNOT     // DUpf16
    DD  @LINEOBL24BITSNOT     // DUpf24
    DD  @LINEOBL32BITSNOT     // DUpf32
    // PEN AND PIXELS :
    DD  @LINEOBL01BITSANDPEN  // DUpf1   // NOT YET SUPPORTED
    DD  @LINEOBL04BITSANDPEN  // DUpf4   // NOT YET SUPPORTED
    DD  @LINEOBL08BITSANDPEN  // DUpf8
    DD  @LINEOBL16BITSANDPEN  // DUpf15
    DD  @LINEOBL16BITSANDPEN  // DUpf16
    DD  @LINEOBL24BITSANDPEN  // DUpf24
    DD  @LINEOBL32BITSANDPEN  // DUpf32
    // PEN OR PIXELS :
    DD  @LINEOBL01BITSORPEN   // DUpf1   // NOT YET SUPPORTED
    DD  @LINEOBL04BITSORPEN   // DUpf4   // NOT YET SUPPORTED
    DD  @LINEOBL08BITSORPEN   // DUpf8
    DD  @LINEOBL16BITSORPEN   // DUpf15
    DD  @LINEOBL16BITSORPEN   // DUpf16
    DD  @LINEOBL24BITSORPEN   // DUpf24
    DD  @LINEOBL32BITSORPEN   // DUpf32
    // PEN XOR PIXELS :
    DD  @LINEOBL01BITSXORPEN  // DUpf1   // NOT YET SUPPORTED
    DD  @LINEOBL04BITSXORPEN  // DUpf4   // NOT YET SUPPORTED
    DD  @LINEOBL08BITSXORPEN  // DUpf8
    DD  @LINEOBL16BITSXORPEN  // DUpf15
    DD  @LINEOBL16BITSXORPEN  // DUpf16
    DD  @LINEOBL24BITSXORPEN  // DUpf24
    DD  @LINEOBL32BITSXORPEN  // DUpf32
    // PEN ALPHA PIXELS :
    DD  @LINEOBL01BITSCOPYPEN  // DUpf1  // ALPHA IS NOT SUPPORTED FOR LOW RESOLUTION
    DD  @LINEOBL04BITSCOPYPEN  // DUpf4  // ALPHA IS NOT SUPPORTED FOR LOW RESOLUTION
    DD  @LINEOBL08BITSCOPYPEN  // DUpf8  // ALPHA IS NOT SUPPORTED FOR LOW RESOLUTION
    DD  @LINEOBL16BITSALPHAPEN // DUpf15 // NOT YET SUPPORTED
    DD  @LINEOBL16BITSALPHAPEN // DUpf16 // NOT YET SUPPORTED
    DD  @LINEOBL24BITSALPHAPEN // DUpf24 // NOT YET SUPPORTED
    DD  @LINEOBL32BITSALPHAPEN // DUpf32 // NOT YET SUPPORTED
    // USER CALL BACK :
    DD  @LINEOBL01BITSUSER    // DUpf1   // NOT YET SUPPORTED
    DD  @LINEOBL04BITSUSER    // DUpf4   // NOT YET SUPPORTED
    DD  @LINEOBL08BITSUSER    // DUpf8   // NOT YET SUPPORTED
    DD  @LINEOBL16BITSUSER    // DUpf15  // NOT YET SUPPORTED
    DD  @LINEOBL16BITSUSER    // DUpf16  // NOT YET SUPPORTED
    DD  @LINEOBL24BITSUSER    // DUpf24  // NOT YET SUPPORTED
    DD  @LINEOBL32BITSUSER    // DUpf32  // NOT YET SUPPORTED


  //************* SOUS ROUTINES DE TRACE *************

  @INIADR: // Sélection de la sous-routine d'initialisation
    MOV   EAX, Resl
    MOV   EAX, DWORD PTR [ EAX*4 + @INITable ]
    JMP   EAX

    @INITable: // TDUPixelFormat = (DUpf1, DUpf4, DUpf8, DUpf15, DUpf16, DUpf24, DUpf32, DUpfCustom);
      DD  @INIADR01    // DUpf1
      DD  @INIADR04    // DUpf4
      DD  @INIADR08    // DUpf8
      DD  @INIADR16    // DUpf15
      DD  @INIADR16    // DUpf16
      DD  @INIADR24    // DUpf24
      DD  @INIADR32    // DUpf32

    @INIADR01:
      RET

    @INIADR04:
      RET

    @INIADR08:
      // On a déjà : AdXPlus := I(PxB);
      // Pt := Seg.y1*DIBWidth_b+Seg.x1;
      MOV EDI, Pt
      ADD EDI, AdXPlus
      MOV EAX, PasX
      MOV AdXPlus, EAX         // AdXPlus est MAJ !
      RET

    @INIADR16:
      // On a déjà : AdXPlus := I(PxW);
      // Pt := Seg.y1*DIBWidth16+Seg.x1;
      MOV EAX, Pt
      MOV EDI, AdXPlus
      LEA EDI, [EDI + EAX * 2] // ESI est MAJ !
      MOV EAX, PasX
      SHL EAX, 1
      MOV AdXPlus, EAX         // AdXPlus est MAJ !
      SHL AdYPlus, 1           // AdYPlus est MAJ !
      RET

    @INIADR24:
      // On a déjà : AdXPlus := I(PxB);
      // Pt := Seg.y1*DIBWidth_b + Seg.x1*3;
      MOV EDI, Pt
      ADD EDI, AdXPlus
      MOV EAX, PasX
      LEA EAX, [ EAX + EAX * 2]
      MOV AdXPlus, EAX         // AdXPlus est MAJ !
      MOV EAX, Coul
      SHR EAX, 16
      MOV CoulTmp, EAX
      RET

    @INIADR32:
      // On a déjà : AdXPlus := I(PxW);
      // Pt := Seg.y1*DIBWidth + Seg.x1;
      MOV EAX, Pt
      MOV EDI, AdXPlus
      LEA EDI, [EDI + EAX * 4] // ESI est MAJ !
      MOV EAX, PasX
      SHL EAX, 2
      MOV AdXPlus, EAX         // AdXPlus est MAJ !
      SHL AdYPlus, 2           // AdYPlus est MAJ !
      RET

  // Fin de la sous-routine d'initialisation

  //#############################################
  //************ LIGNES HORIZONTALES ************
  //#############################################

  // ########## COPY PEN ###########

  @LINEHORZT01BITSCOPYPEN: // Tracé de la ligne horizontale
    RET

  @LINEHORZT04BITSCOPYPEN: // Tracé de la ligne horizontale
    RET

  @LINEHORZT08BITSCOPYPEN: // Tracé de la ligne horizontale
    MOV  EAX, Coul
    @RepeatLNX08COPYPEN:
      ROL  MASQUE, 1            // Repeat
      JNC  @LNX08NOTRACECOPYPEN //   If PlotON
      MOV  [EDI], AL            //
    @LNX08NOTRACECOPYPEN:       //     Else ;
      ADD  EDI, AdXPlus         //   Inc(Pt,AdXPlus);
      SUB  ECX, PasX            //   Dec(dx, PasX)
      JNZ  @RepeatLNX08COPYPEN  //   Until (dx=0);
    ADD EDI, AdYPlus            // Inc(Pt,AdYPlus)
    RET

  @LINEHORZT16BITSCOPYPEN: // Tracé de la ligne horizontale
    MOV  EAX, Coul
    @RepeatLNX16COPYPEN:
      ROL  MASQUE, 1            // Repeat
      JNC  @LNX16NOTRACECOPYPEN //   If PlotON
      MOV  [EDI], AX            //
    @LNX16NOTRACECOPYPEN:       //     Else ;
      ADD  EDI, AdXPlus         //   Inc(Pt,AdXPlus);
      SUB  ECX, PasX            //   Dec(dx, PasX)
      JNZ  @RepeatLNX16COPYPEN  //   Until (dx=0);
    ADD EDI, AdYPlus            // Inc(Pt,AdYPlus)
    RET

  @LINEHORZT24BITSCOPYPEN: // Tracé de la ligne horizontale
    MOV  EAX, Coul
    MOV  EBX, CoulTmp     // Permutation temporaire avec la couleur Rouge
    @RepeatLNX24COPYPEN:
      ROL  MASQUE, 1            // Repeat
      JNC  @LNX24NOTRACECOPYPEN //   If PlotON Then Begin
      MOV  [EDI+0], AL          //
      MOV  [EDI+1], AH          //
      MOV  [EDI+2], BL          //
    @LNX24NOTRACECOPYPEN:       //   End Else ;        ----------
      ADD  EDI, AdXPlus         //   Inc(Pt,AdXPlus);   = 24 bits
      SUB  ECX, PasX            //   Dec(dx, PasX)
      JNZ  @RepeatLNX24COPYPEN  //  Until (dx=0);
    MOV  EBX, PasY
    ADD  EDI, AdYPlus           // Inc(Pt,AdYPlus)
    RET

  @LINEHORZT32BITSCOPYPEN: // Tracé de la ligne horizontale
    MOV  EAX, Coul
    @RepeatLNX32COPYPEN:
      ROL  MASQUE, 1             // Repeat
      JNC  @LNX32NOTRACECOPYPEN  //   If PlotON
      MOV  [EDI], EAX            //
    @LNX32NOTRACECOPYPEN:        //     Else ;
      ADD  EDI, AdXPlus          //   Inc(Pt,AdXPlus);
      SUB  ECX, PasX             //   Dec(dx, PasX)
      JNZ  @RepeatLNX32COPYPEN   //   Until (dx=0);
    ADD EDI, AdYPlus             // Inc(Pt,AdYPlus)
    RET

  // ########## NOT PIXELS ###########

  @LINEHORZT01BITSNOT: // Tracé de la ligne horizontale
    RET

  @LINEHORZT04BITSNOT: // Tracé de la ligne horizontale
    RET

  @LINEHORZT08BITSNOT: // Tracé de la ligne horizontale
    @RepeatLNX08NOT:
      ROL  MASQUE, 1
      JNC  @LNX08NOTRACENOT
      NOT  BYTE PTR [EDI]
    @LNX08NOTRACENOT:
      ADD  EDI, AdXPlus
      SUB  ECX, PasX
      JNZ  @RepeatLNX08NOT
    ADD EDI, AdYPlus
    RET

  @LINEHORZT16BITSNOT: // Tracé de la ligne horizontale
    @RepeatLNX16NOT:
      ROL  MASQUE, 1
      JNC  @LNX16NOTRACENOT
      NOT  WORD PTR [EDI]
    @LNX16NOTRACENOT:
      ADD  EDI, AdXPlus
      SUB  ECX, PasX
      JNZ  @RepeatLNX16NOT
    ADD EDI, AdYPlus
    RET

  @LINEHORZT24BITSNOT: // Tracé de la ligne horizontale
    @RepeatLNX24NOT:
      ROL  MASQUE, 1
      JNC  @LNX24NOTRACENOT
      NOT  BYTE PTR [EDI+0]
      NOT  BYTE PTR [EDI+1]
      NOT  BYTE PTR [EDI+2]
    @LNX24NOTRACENOT:
      ADD  EDI, AdXPlus
      SUB  ECX, PasX
      JNZ  @RepeatLNX24NOT
    MOV  EBX, PasY
    ADD  EDI, AdYPlus
    RET

  @LINEHORZT32BITSNOT: // Tracé de la ligne horizontale
    @RepeatLNX32NOT:
      ROL  MASQUE, 1
      JNC  @LNX32NOTRACENOT
      NOT  DWORD PTR [EDI]
    @LNX32NOTRACENOT:
      ADD  EDI, AdXPlus
      SUB  ECX, PasX
      JNZ  @RepeatLNX32NOT
    ADD EDI, AdYPlus
    RET

  // ########## PEN AND PIXELS ###########

  @LINEHORZT01BITSANDPEN: // Tracé de la ligne hANDizontale
    RET

  @LINEHORZT04BITSANDPEN: // Tracé de la ligne hANDizontale
    RET

  @LINEHORZT08BITSANDPEN: // Tracé de la ligne hANDizontale
    MOV  EAX, Coul
    @RepeatLNX08ANDPEN:
      ROL  MASQUE, 1
      JNC  @LNX08NOTRACEANDPEN
      AND  [EDI], AL
    @LNX08NOTRACEANDPEN:
      ADD  EDI, AdXPlus
      SUB  ECX, PasX
      JNZ  @RepeatLNX08ANDPEN
    ADD EDI, AdYPlus
    RET

  @LINEHORZT16BITSANDPEN: // Tracé de la ligne hANDizontale
    MOV  EAX, Coul
    @RepeatLNX16ANDPEN:
      ROL  MASQUE, 1
      JNC  @LNX16NOTRACEANDPEN
      AND  [EDI], AX
    @LNX16NOTRACEANDPEN:
      ADD  EDI, AdXPlus
      SUB  ECX, PasX
      JNZ  @RepeatLNX16ANDPEN
    ADD EDI, AdYPlus
    RET

  @LINEHORZT24BITSANDPEN: // Tracé de la ligne hANDizontale
    MOV  EAX, Coul
    MOV  EBX, CoulTmp
    @RepeatLNX24ANDPEN:
      ROL  MASQUE, 1
      JNC  @LNX24NOTRACEANDPEN
      AND  [EDI+0], AL
      AND  [EDI+1], AH
      AND  [EDI+2], BL
    @LNX24NOTRACEANDPEN:
      ADD  EDI, AdXPlus
      SUB  ECX, PasX
      JNZ  @RepeatLNX24ANDPEN
    MOV  EBX, PasY
    ADD  EDI, AdYPlus
    RET

  @LINEHORZT32BITSANDPEN: // Tracé de la ligne horizontale
    MOV  EAX, Coul
    @RepeatLNX32ANDPEN:
      ROL  MASQUE, 1
      JNC  @LNX32NOTRACEANDPEN
      AND   [EDI], EAX
    @LNX32NOTRACEANDPEN:
      ADD  EDI, AdXPlus
      SUB  ECX, PasX
      JNZ  @RepeatLNX32ANDPEN
    ADD EDI, AdYPlus
    RET

  // ########## PEN OR PIXELS ###########

  @LINEHORZT01BITSORPEN: // Tracé de la ligne horizontale
    RET

  @LINEHORZT04BITSORPEN: // Tracé de la ligne horizontale
    RET

  @LINEHORZT08BITSORPEN: // Tracé de la ligne horizontale
    MOV  EAX, Coul
    @RepeatLNX08ORPEN:
      ROL  MASQUE, 1
      JNC  @LNX08NOTRACEORPEN
      OR   [EDI], AL
    @LNX08NOTRACEORPEN:
      ADD  EDI, AdXPlus
      SUB  ECX, PasX
      JNZ  @RepeatLNX08ORPEN
    ADD EDI, AdYPlus
    RET

  @LINEHORZT16BITSORPEN: // Tracé de la ligne horizontale
    MOV  EAX, Coul
    @RepeatLNX16ORPEN:
      ROL  MASQUE, 1
      JNC  @LNX16NOTRACEORPEN
      OR   [EDI], AX
    @LNX16NOTRACEORPEN:
      ADD  EDI, AdXPlus
      SUB  ECX, PasX
      JNZ  @RepeatLNX16ORPEN
    ADD EDI, AdYPlus
    RET

  @LINEHORZT24BITSORPEN: // Tracé de la ligne horizontale
    MOV  EAX, Coul
    MOV  EBX, CoulTmp
    @RepeatLNX24ORPEN:
      ROL  MASQUE, 1
      JNC  @LNX24NOTRACEORPEN
      OR   [EDI+0], AL
      OR   [EDI+1], AH
      OR   [EDI+2], BL
    @LNX24NOTRACEORPEN:
      ADD  EDI, AdXPlus
      SUB  ECX, PasX
      JNZ  @RepeatLNX24ORPEN
    MOV  EBX, PasY
    ADD  EDI, AdYPlus
    RET

  @LINEHORZT32BITSORPEN: // Tracé de la ligne horizontale
    MOV  EAX, Coul
    @RepeatLNX32ORPEN:
      ROL  MASQUE, 1
      JNC  @LNX32NOTRACEORPEN
      OR   [EDI], EAX
    @LNX32NOTRACEORPEN:
      ADD  EDI, AdXPlus
      SUB  ECX, PasX
      JNZ  @RepeatLNX32ORPEN
    ADD EDI, AdYPlus
    RET

  // ########## PEN XOR PIXELS ###########

  @LINEHORZT01BITSXORPEN: // Tracé de la ligne horizontale
    RET

  @LINEHORZT04BITSXORPEN: // Tracé de la ligne horizontale
    RET

  @LINEHORZT08BITSXORPEN: // Tracé de la ligne horizontale
    MOV  EAX, Coul
    @RepeatLNX08XORPEN:
      ROL  MASQUE, 1      // Repeat
      JNC  @LNX08NOTRACEXORPEN  //   If PlotON
      XOR  [EDI], AL      //
    @LNX08NOTRACEXORPEN:        //     Else ;
      ADD  EDI, AdXPlus   //   Inc(Pt,AdXPlus);
      SUB  ECX, PasX      //   Dec(dx, PasX)
      JNZ  @RepeatLNX08XORPEN   //   Until (dx=0);
    ADD EDI, AdYPlus      // Inc(Pt,AdYPlus)
    RET

  @LINEHORZT16BITSXORPEN: // Tracé de la ligne horizontale
    MOV  EAX, Coul
    @RepeatLNX16XORPEN:
      ROL  MASQUE, 1      // Repeat
      JNC  @LNX16NOTRACEXORPEN  //   If PlotON
      XOR  [EDI], AX      //
    @LNX16NOTRACEXORPEN:        //     Else ;
      ADD  EDI, AdXPlus   //   Inc(Pt,AdXPlus);
      SUB  ECX, PasX      //   Dec(dx, PasX)
      JNZ  @RepeatLNX16XORPEN   //   Until (dx=0);
    ADD EDI, AdYPlus      // Inc(Pt,AdYPlus)
    RET

  @LINEHORZT24BITSXORPEN: // Tracé de la ligne horizontale
    MOV  EAX, Coul
    MOV  EBX, CoulTmp     // Permutation temporaire avec la couleur Rouge
    @RepeatLNX24XORPEN:
      ROL  MASQUE, 1      // Repeat
      JNC  @LNX24NOTRACEXORPEN  //   If PlotON Then Begin
      XOR  [EDI+0], AL    //
      XOR  [EDI+1], AH    //
      XOR  [EDI+2], BL    //
    @LNX24NOTRACEXORPEN:        //   End Else ;                           ----------
      ADD  EDI, AdXPlus   //   Inc(Pt,AdXPlus);                     = 24 bits
      SUB  ECX, PasX      //   Dec(dx, PasX)
      JNZ  @RepeatLNX24XORPEN   //   Until (dx=0);
    MOV  EBX, PasY
    ADD  EDI, AdYPlus     // Inc(Pt,AdYPlus)
    RET

  @LINEHORZT32BITSXORPEN: // Tracé de la ligne horizontale
    MOV  EAX, Coul
    @RepeatLNX32XORPEN:
      ROL  MASQUE, 1      // Repeat
      JNC  @LNX32NOTRACEXORPEN  //   If PlotON
      XOR  [EDI], EAX     //
    @LNX32NOTRACEXORPEN:        //     Else ;
      ADD  EDI, AdXPlus   //   Inc(Pt,AdXPlus);
      SUB  ECX, PasX      //   Dec(dx, PasX)
      JNZ  @RepeatLNX32XORPEN   //   Until (dx=0);
    ADD EDI, AdYPlus      // Inc(Pt,AdYPlus)
    RET

  // ########## PEN ALPHA PIXELS ###########

  @LINEHORZT16BITSALPHAPEN:
  @LINEHORZT24BITSALPHAPEN:
  @LINEHORZT32BITSALPHAPEN:
    // Surprise ! Soon...
    RET

  // ########## CALLBACK FUNCTION ###########

  @LINEHORZT01BITSUSER:
  @LINEHORZT04BITSUSER:
  @LINEHORZT08BITSUSER:
  @LINEHORZT16BITSUSER:
  @LINEHORZT24BITSUSER:
  @LINEHORZT32BITSUSER:
    // Surprise ! Soon...
    RET

  //#############################################
  //************* LIGNES VERTICALES *************
  //#############################################

  @LINEVERT01BITSCOPYPEN: // Tracé de la ligne verticale
    RET

  @LINEVERT04BITSCOPYPEN: // Tracé de la ligne verticale
    RET

  @LINEVERT08BITSCOPYPEN: // Tracé de la ligne verticale
    MOV  EAX, Coul
    @RepeatLNY08COPYPEN:
      ROL  MASQUE, 1      // Repeat
      JNC  @LNY08NOTRACECOPYPEN  //   If PlotON
      MOV  [EDI], AL      //     Then PxB^[Pt] := CoulB; <--- [Mem] <= AX (8 bits)
    @LNY08NOTRACECOPYPEN:        //     Else ;
      ADD  EDI, AdYPlus   //   Inc(Pt,AdYPlus);
      SUB  ECX, PasY      //   Dec(dy, PasY)
      JNZ  @RepeatLNY08COPYPEN   //   Until (dy=0);
    ADD EDI, AdXPlus      // Inc(Pt,AdXPlus)
    RET

  @LINEVERT16BITSCOPYPEN: // Tracé de la ligne verticale
    MOV  EAX, Coul
    @RepeatLNY16COPYPEN:
      ROL  MASQUE, 1      // Repeat
      JNC  @LNY16NOTRACECOPYPEN  //   If PlotON
      MOV  [EDI], AX      //     Then PxW^[Pt] := CoulW; <--- [Mem] <= AX (16 bits)
    @LNY16NOTRACECOPYPEN:        //     Else ;
      ADD  EDI, AdYPlus   //   Inc(Pt,AdYPlus);
      SUB  ECX, PasY      //   Dec(dy, PasY)
      JNZ  @RepeatLNY16COPYPEN   //   Until (dy=0);
    ADD EDI, AdXPlus      // Inc(Pt,AdXPlus)
    RET

  @LINEVERT24BITSCOPYPEN: // Tracé de la ligne verticale
    MOV  EAX, Coul
    MOV  EBX, CoulTmp     // Permutation temporaire avec la couleur Rouge
    @RepeatLNY24COPYPEN:
      ROL  MASQUE, 1      // Repeat
      JNC  @LNY24NOTRACECOPYPEN  //   If PlotON Then Begin
      MOV  [EDI+0], AL    //     PxB^[Pt] := CoulB; <--- [Mem] <= AL (8 bits)
      MOV  [EDI+1], AH    //     PxB^[Pt] := CoulV; <--- [Mem] <= AH (8 bits)
      MOV  [EDI+2], BL    //     PxB^[Pt] := CoulR; <--- [Mem] <= DH (8 bits)
    @LNY24NOTRACECOPYPEN:        //   End Else ;                           ----------
      ADD  EDI, AdYPlus   //   Inc(Pt,AdYPlus);                     = 24 bits
      SUB  ECX, PasY      //   Dec(dy, PasY)
      JNZ  @RepeatLNY24COPYPEN   //   Until (dy=0);
    MOV  EBX, PasX
    ADD  EDI, AdXPlus     // Inc(Pt,AdXPlus)
    RET

  @LINEVERT32BITSCOPYPEN: // Tracé de la ligne verticale
    MOV  EAX, Coul
    @RepeatLNY32COPYPEN:
      ROL  MASQUE, 1      // Repeat
      JNC  @LNY32NOTRACECOPYPEN  //   If PlotON
      MOV  [EDI], EAX     //     Then PxL^[Pt] := CoulL; <--- [Mem] <= EAX (32 bits)
    @LNY32NOTRACECOPYPEN:        //     Else ;
      ADD  EDI, AdYPlus   //   Inc(Pt,AdYPlus);
      SUB  ECX, PasY      //   Dec(dy, PasY)
      JNZ  @RepeatLNY32COPYPEN   //   Until (dy=0);
    ADD EDI, AdXPlus      // Inc(Pt,AdXPlus)
    RET

  @LINEVERT01BITSNOT: // Tracé de la ligne verticale
    RET

  @LINEVERT04BITSNOT: // Tracé de la ligne verticale
    RET

  @LINEVERT08BITSNOT: // Tracé de la ligne verticale
    @RepeatLNY08NOT:
      ROL  MASQUE, 1      // Repeat
      JNC  @LNY08NOTRACENOT  //   If PlotON
      NOT  BYTE PTR [EDI]
    @LNY08NOTRACENOT:        //     Else ;
      ADD  EDI, AdYPlus   //   Inc(Pt,AdYPlus);
      SUB  ECX, PasY      //   Dec(dy, PasY)
      JNZ  @RepeatLNY08NOT   //   Until (dy=0);
    ADD EDI, AdXPlus      // Inc(Pt,AdXPlus)
    RET

  @LINEVERT16BITSNOT: // Tracé de la ligne verticale
    @RepeatLNY16NOT:
      ROL  MASQUE, 1      // Repeat
      JNC  @LNY16NOTRACENOT  //   If PlotON
      NOT  WORD PTR [EDI]
    @LNY16NOTRACENOT:        //     Else ;
      ADD  EDI, AdYPlus   //   Inc(Pt,AdYPlus);
      SUB  ECX, PasY      //   Dec(dy, PasY)
      JNZ  @RepeatLNY16NOT   //   Until (dy=0);
    ADD EDI, AdXPlus      // Inc(Pt,AdXPlus)
    RET

  @LINEVERT24BITSNOT: // Tracé de la ligne verticale
    @RepeatLNY24NOT:
      ROL  MASQUE, 1      // Repeat
      JNC  @LNY24NOTRACENOT  //   If PlotON Then Begin
      NOT  BYTE PTR [EDI+0]
      NOT  BYTE PTR [EDI+1]
      NOT  BYTE PTR [EDI+2]
    @LNY24NOTRACENOT:        //   End Else ;                           ----------
      ADD  EDI, AdYPlus   //   Inc(Pt,AdYPlus);                     = 24 bits
      SUB  ECX, PasY      //   Dec(dy, PasY)
      JNZ  @RepeatLNY24NOT   //   Until (dy=0);
    MOV  EBX, PasX
    ADD  EDI, AdXPlus     // Inc(Pt,AdXPlus)
    RET

  @LINEVERT32BITSNOT: // Tracé de la ligne verticale
    @RepeatLNY32NOT:
      ROL  MASQUE, 1      // Repeat
      JNC  @LNY32NOTRACENOT  //   If PlotON
      NOT  DWORD PTR [EDI]
    @LNY32NOTRACENOT:        //     Else ;
      ADD  EDI, AdYPlus   //   Inc(Pt,AdYPlus);
      SUB  ECX, PasY      //   Dec(dy, PasY)
      JNZ  @RepeatLNY32NOT   //   Until (dy=0);
    ADD EDI, AdXPlus      // Inc(Pt,AdXPlus)
    RET

  @LINEVERT01BITSANDPEN: // Tracé de la ligne verticale
    RET

  @LINEVERT04BITSANDPEN: // Tracé de la ligne verticale
    RET

  @LINEVERT08BITSANDPEN: // Tracé de la ligne verticale
    MOV  EAX, Coul
    @RepeatLNY08ANDPEN:
      ROL  MASQUE, 1      // Repeat
      JNC  @LNY08NOTRACEANDPEN  //   If PlotON
      AND  [EDI], AL      //
    @LNY08NOTRACEANDPEN:        //     Else ;
      ADD  EDI, AdYPlus   //   Inc(Pt,AdYPlus);
      SUB  ECX, PasY      //   Dec(dy, PasY)
      JNZ  @RepeatLNY08ANDPEN   //   Until (dy=0);
    ADD EDI, AdXPlus      // Inc(Pt,AdXPlus)
    RET

  @LINEVERT16BITSANDPEN: // Tracé de la ligne verticale
    MOV  EAX, Coul
    @RepeatLNY16ANDPEN:
      ROL  MASQUE, 1      // Repeat
      JNC  @LNY16NOTRACEANDPEN  //   If PlotON
      AND  [EDI], AX      //
    @LNY16NOTRACEANDPEN:        //     Else ;
      ADD  EDI, AdYPlus   //   Inc(Pt,AdYPlus);
      SUB  ECX, PasY      //   Dec(dy, PasY)
      JNZ  @RepeatLNY16ANDPEN   //   Until (dy=0);
    ADD EDI, AdXPlus      // Inc(Pt,AdXPlus)
    RET

  @LINEVERT24BITSANDPEN: // Tracé de la ligne verticale
    MOV  EAX, Coul
    MOV  EBX, CoulTmp     // Permutation temporaire avec la couleur Rouge
    @RepeatLNY24ANDPEN:
      ROL  MASQUE, 1      // Repeat
      JNC  @LNY24NOTRACEANDPEN  //   If PlotON Then Begin
      AND  [EDI+0], AL    //
      AND  [EDI+1], AH    //
      AND  [EDI+2], BL    //
    @LNY24NOTRACEANDPEN:        //   End Else ;                           ----------
      ADD  EDI, AdYPlus   //   Inc(Pt,AdYPlus);                     = 24 bits
      SUB  ECX, PasY      //   Dec(dy, PasY)
      JNZ  @RepeatLNY24ANDPEN   //   Until (dy=0);
    MOV  EBX, PasX
    ADD  EDI, AdXPlus     // Inc(Pt,AdXPlus)
    RET

  @LINEVERT32BITSANDPEN: // Tracé de la ligne verticale
    MOV  EAX, Coul
    @RepeatLNY32ANDPEN:
      ROL  MASQUE, 1      // Repeat
      JNC  @LNY32NOTRACEANDPEN  //   If PlotON
      AND  [EDI], EAX     //     Then PxL^[Pt] := CoulL; <--- [Mem] <= EAX (32 bits)
    @LNY32NOTRACEANDPEN:        //     Else ;
      ADD  EDI, AdYPlus   //   Inc(Pt,AdYPlus);
      SUB  ECX, PasY      //   Dec(dy, PasY)
      JNZ  @RepeatLNY32ANDPEN   //   Until (dy=0);
    ADD EDI, AdXPlus      // Inc(Pt,AdXPlus)
    RET

  @LINEVERT01BITSORPEN: // Tracé de la ligne verticale
    RET

  @LINEVERT04BITSORPEN: // Tracé de la ligne verticale
    RET

  @LINEVERT08BITSORPEN: // Tracé de la ligne verticale
    MOV  EAX, Coul
    @RepeatLNY08ORPEN:
      ROL  MASQUE, 1      // Repeat
      JNC  @LNY08NOTRACEORPEN  //   If PlotON
      OR   [EDI], AL      //
    @LNY08NOTRACEORPEN:        //     Else ;
      ADD  EDI, AdYPlus   //   Inc(Pt,AdYPlus);
      SUB  ECX, PasY      //   Dec(dy, PasY)
      JNZ  @RepeatLNY08ORPEN   //   Until (dy=0);
    ADD EDI, AdXPlus      // Inc(Pt,AdXPlus)
    RET

  @LINEVERT16BITSORPEN: // Tracé de la ligne verticale
    MOV  EAX, Coul
    @RepeatLNY16ORPEN:
      ROL  MASQUE, 1      // Repeat
      JNC  @LNY16NOTRACEORPEN  //   If PlotON
      OR   [EDI], AX      //
    @LNY16NOTRACEORPEN:        //     Else ;
      ADD  EDI, AdYPlus   //   Inc(Pt,AdYPlus);
      SUB  ECX, PasY      //   Dec(dy, PasY)
      JNZ  @RepeatLNY16ORPEN   //   Until (dy=0);
    ADD EDI, AdXPlus      // Inc(Pt,AdXPlus)
    RET

  @LINEVERT24BITSORPEN: // Tracé de la ligne verticale
    MOV  EAX, Coul
    MOV  EBX, CoulTmp     // Permutation temporaire avec la couleur Rouge
    @RepeatLNY24ORPEN:
      ROL  MASQUE, 1      // Repeat
      JNC  @LNY24NOTRACEORPEN  //   If PlotON Then Begin
      OR   [EDI+0], AL    //
      OR   [EDI+1], AH    //
      OR   [EDI+2], BL    //
    @LNY24NOTRACEORPEN:        //   End Else ;                           ----------
      ADD  EDI, AdYPlus   //   Inc(Pt,AdYPlus);                     = 24 bits
      SUB  ECX, PasY      //   Dec(dy, PasY)
      JNZ  @RepeatLNY24ORPEN   //   Until (dy=0);
    MOV  EBX, PasX
    ADD  EDI, AdXPlus     // Inc(Pt,AdXPlus)
    RET

  @LINEVERT32BITSORPEN: // Tracé de la ligne verticale
    MOV  EAX, Coul
    @RepeatLNY32ORPEN:
      ROL  MASQUE, 1      // Repeat
      JNC  @LNY32NOTRACEORPEN  //   If PlotON
      OR   [EDI], EAX     //
    @LNY32NOTRACEORPEN:        //     Else ;
      ADD  EDI, AdYPlus   //   Inc(Pt,AdYPlus);
      SUB  ECX, PasY      //   Dec(dy, PasY)
      JNZ  @RepeatLNY32ORPEN   //   Until (dy=0);
    ADD EDI, AdXPlus      // Inc(Pt,AdXPlus)
    RET

  @LINEVERT01BITSXORPEN: // Tracé de la ligne verticale
    RET

  @LINEVERT04BITSXORPEN: // Tracé de la ligne verticale
    RET

  @LINEVERT08BITSXORPEN: // Tracé de la ligne verticale
    MOV  EAX, Coul
    @RepeatLNY08XORPEN:
      ROL  MASQUE, 1      // Repeat
      JNC  @LNY08NOTRACEXORPEN  //   If PlotON
      XOR  [EDI], AL      //
    @LNY08NOTRACEXORPEN:        //     Else ;
      ADD  EDI, AdYPlus   //   Inc(Pt,AdYPlus);
      SUB  ECX, PasY      //   Dec(dy, PasY)
      JNZ  @RepeatLNY08XORPEN   //   Until (dy=0);
    ADD EDI, AdXPlus      // Inc(Pt,AdXPlus)
    RET

  @LINEVERT16BITSXORPEN: // Tracé de la ligne verticale
    MOV  EAX, Coul
    @RepeatLNY16XORPEN:
      ROL  MASQUE, 1      // Repeat
      JNC  @LNY16NOTRACEORPEN  //   If PlotON
      XOR  [EDI], AX      //
    @LNY16NOTRACEXORPEN:        //     Else ;
      ADD  EDI, AdYPlus   //   Inc(Pt,AdYPlus);
      SUB  ECX, PasY      //   Dec(dy, PasY)
      JNZ  @RepeatLNY16XORPEN   //   Until (dy=0);
    ADD EDI, AdXPlus      // Inc(Pt,AdXPlus)
    RET

  @LINEVERT24BITSXORPEN: // Tracé de la ligne verticale
    MOV  EAX, Coul
    MOV  EBX, CoulTmp     // Permutation temporaire avec la couleur Rouge
    @RepeatLNY24XORPEN:
      ROL  MASQUE, 1      // Repeat
      JNC  @LNY24NOTRACEXORPEN  //   If PlotON Then Begin
      XOR  [EDI+0], AL    //
      XOR  [EDI+1], AH    //
      XOR  [EDI+2], BL    //
    @LNY24NOTRACEXORPEN:        //   End Else ;                           ----------
      ADD  EDI, AdYPlus   //   Inc(Pt,AdYPlus);                     = 24 bits
      SUB  ECX, PasY      //   Dec(dy, PasY)
      JNZ  @RepeatLNY24XORPEN   //   Until (dy=0);
    MOV  EBX, PasX
    ADD  EDI, AdXPlus     // Inc(Pt,AdXPlus)
    RET

  @LINEVERT32BITSXORPEN: // Tracé de la ligne verticale
    MOV  EAX, Coul
    @RepeatLNY32XORPEN:
      ROL  MASQUE, 1      // Repeat
      JNC  @LNY32NOTRACEXORPEN  //   If PlotON
      XOR  [EDI], EAX     //
    @LNY32NOTRACEXORPEN:        //     Else ;
      ADD  EDI, AdYPlus   //   Inc(Pt,AdYPlus);
      SUB  ECX, PasY      //   Dec(dy, PasY)
      JNZ  @RepeatLNY32XORPEN   //   Until (dy=0);
    ADD EDI, AdXPlus      // Inc(Pt,AdXPlus)
    RET

  @LINEVERT16BITSALPHAPEN:
  @LINEVERT24BITSALPHAPEN:
  @LINEVERT32BITSALPHAPEN:
    // Surprise ! Soon...
    RET

  // ########## CALLBACK FUNCTION ###########

  @LINEVERT01BITSUSER:
  @LINEVERT04BITSUSER:
  @LINEVERT08BITSUSER:
  @LINEVERT16BITSUSER:
  @LINEVERT24BITSUSER:
  @LINEVERT32BITSUSER:
    // Surprise ! Soon...
    RET

  //************* LIGNES OBLIQUES *************

  @LINEOBL01BITSCOPYPEN: // Tracé de la ligne oblique
    RET

  @LINEOBL04BITSCOPYPEN: // Tracé de la ligne oblique
    RET

  @LINEOBL08BITSCOPYPEN: // Tracé de la ligne oblique
    MOV  EAX, Coul
    MOV  EDX, AdXPlus
    @RepeatLNXY08COPYPEN:
      ROL  MASQUE, 1      // Repeat
      JNC  @LNXY08NOTRACECOPYPEN //   If PlotON
      MOV  [EDI], AL      //     Then PxB^[Pt] := CoulB; <--- [Mem] <= AL (8 bits)
    @LNXY08NOTRACECOPYPEN:       //     Else ;
      ADD  EDI, EDX       //   Inc(Pt,AdXYPlus);
      SUB  ECX, EBX       //   Dec(dx, PasX)
      JNZ  @RepeatLNXY08COPYPEN  //   Until (dx=0);
    RET                   // Nota : AdXPlus a ici la valeur (AdXPlus + AdYPlus)

  @LINEOBL16BITSCOPYPEN: // Tracé de la ligne oblique
    MOV  EAX, Coul
    MOV  EDX, AdXPlus
    @RepeatLNXY16COPYPEN:
      ROL  MASQUE, 1      // Repeat
      JNC  @LNXY16NOTRACECOPYPEN //   If PlotON
      MOV  [EDI], AX      //     Then PxW^[Pt] := CoulW; <--- [Mem] <= AX (16 bits)
    @LNXY16NOTRACECOPYPEN:       //     Else ;
      ADD  EDI, EDX       //   Inc(Pt,AdXYPlus);
      SUB  ECX, EBX       //   Dec(dx, PasX)
      JNZ  @RepeatLNXY16COPYPEN  //   Until (dx=0);
    RET                   // Nota : AdXPlus a ici la valeur (AdXPlus + AdYPlus)

  @LINEOBL24BITSCOPYPEN: // Tracé de la ligne oblique
    MOV  EAX, Coul
    MOV  EDX, CoulTmp
    @RepeatLNXY24COPYPEN:
      ROL  MASQUE, 1      // Repeat
      JNC  @LNXY24NOTRACECOPYPEN //   If PlotON
      MOV  [EDI+0], AL    //     PxB^[Pt] := CoulB; <--- [Mem] <= AL (8 bits)
      MOV  [EDI+1], AH    //     PxB^[Pt] := CoulV; <--- [Mem] <= AH (8 bits)
      MOV  [EDI+2], DL    //     PxB^[Pt] := CoulR; <--- [Mem] <= DH (8 bits)
    @LNXY24NOTRACECOPYPEN:       //     Else ;                             ----------
      ADD  EDI, AdXPlus   //   Inc(Pt,AdXYPlus);                    = 24 bits
      SUB  ECX, EBX       //   Dec(dx, PasX)
      JNZ  @RepeatLNXY24COPYPEN  //   Until (dx=0);
    RET                   // Nota : AdXPlus a ici la valeur (AdXPlus + AdYPlus) = EDX

  @LINEOBL32BITSCOPYPEN: // Tracé de la ligne horizontale
    MOV  EAX, Coul
    MOV  EDX, AdXPlus
    @RepeatLNXY32COPYPEN:
      ROL  MASQUE, 1      // Repeat
      JNC  @LNXY32NOTRACECOPYPEN //   If PlotON
      MOV  [EDI], EAX     //     Then PxW^[Pt] := CoulW; <--- [Mem] <= EAX (32 bits)
    @LNXY32NOTRACECOPYPEN:       //     Else ;
      ADD  EDI, EDX       //   Inc(Pt,AdXYPlus);
      SUB  ECX, EBX       //   Dec(dx, PasX)
      JNZ  @RepeatLNXY32COPYPEN  //   Until (dx=0);
    RET                   // Nota : AdXPlus a ici la valeur (AdXPlus + AdYPlus)

  @LINEOBL01BITSNOT: // Tracé de la ligne oblique
    RET

  @LINEOBL04BITSNOT: // Tracé de la ligne oblique
    RET

  @LINEOBL08BITSNOT: // Tracé de la ligne oblique
    @RepeatLNXY08NOT:
      ROL  MASQUE, 1      // Repeat
      JNC  @LNXY08NOTRACENOT //   If PlotON
      NOT  BYTE PTR [EDI]    //
    @LNXY08NOTRACENOT:       //     Else ;
      ADD  EDI, EDX       //   Inc(Pt,AdXYPlus);
      SUB  ECX, EBX       //   Dec(dx, PasX)
      JNZ  @RepeatLNXY08NOT  //   Until (dx=0);
    RET                   // Nota : AdXPlus a ici la valeur (AdXPlus + AdYPlus)

  @LINEOBL16BITSNOT: // Tracé de la ligne oblique
    @RepeatLNXY16NOT:
      ROL  MASQUE, 1      // Repeat
      JNC  @LNXY16NOTRACENOT //   If PlotON
      NOT  WORD PTR [EDI]    //
    @LNXY16NOTRACENOT:       //     Else ;
      ADD  EDI, EDX       //   Inc(Pt,AdXYPlus);
      SUB  ECX, EBX       //   Dec(dx, PasX)
      JNZ  @RepeatLNXY16NOT  //   Until (dx=0);
    RET                   // Nota : AdXPlus a ici la valeur (AdXPlus + AdYPlus)

  @LINEOBL24BITSNOT: // Tracé de la ligne oblique
    @RepeatLNXY24NOT:
      ROL  MASQUE, 1      // Repeat
      JNC  @LNXY24NOTRACENOT //   If PlotON
      NOT  BYTE PTR [EDI+0]  //
      NOT  BYTE PTR [EDI+1]  //
      NOT  BYTE PTR [EDI+2]  //
    @LNXY24NOTRACENOT:       //     Else ;                             ----------
      ADD  EDI, AdXPlus   //   Inc(Pt,AdXYPlus);                    = 24 bits
      SUB  ECX, EBX       //   Dec(dx, PasX)
      JNZ  @RepeatLNXY24NOT  //   Until (dx=0);
    RET                   // Nota : AdXPlus a ici la valeur (AdXPlus + AdYPlus) = EDX

  @LINEOBL32BITSNOT: // Tracé de la ligne horizontale
    @RepeatLNXY32NOT:
      ROL  MASQUE, 1      // Repeat
      JNC  @LNXY32NOTRACENOT //   If PlotON
      NOT  DWORD PTR [EDI]     //
    @LNXY32NOTRACENOT:       //     Else ;
      ADD  EDI, EDX       //   Inc(Pt,AdXYPlus);
      SUB  ECX, EBX       //   Dec(dx, PasX)
      JNZ  @RepeatLNXY32NOT  //   Until (dx=0);
    RET                   // Nota : AdXPlus a ici la valeur (AdXPlus + AdYPlus)

  @LINEOBL01BITSANDPEN: // Tracé de la ligne oblique
    RET

  @LINEOBL04BITSANDPEN: // Tracé de la ligne oblique
    RET

  @LINEOBL08BITSANDPEN: // Tracé de la ligne oblique
    MOV  EAX, Coul
    MOV  EDX, AdXPlus
    @RepeatLNXY08ANDPEN:
      ROL  MASQUE, 1      // Repeat
      JNC  @LNXY08NOTRACEANDPEN //   If PlotON
      AND  [EDI], AL      //
    @LNXY08NOTRACEANDPEN:       //     Else ;
      ADD  EDI, EDX       //   Inc(Pt,AdXYPlus);
      SUB  ECX, EBX       //   Dec(dx, PasX)
      JNZ  @RepeatLNXY08ANDPEN  //   Until (dx=0);
    RET                   // Nota : AdXPlus a ici la valeur (AdXPlus + AdYPlus)

  @LINEOBL16BITSANDPEN: // Tracé de la ligne oblique
    MOV  EAX, Coul
    MOV  EDX, AdXPlus
    @RepeatLNXY16ANDPEN:
      ROL  MASQUE, 1      // Repeat
      JNC  @LNXY16NOTRACEANDPEN //   If PlotON
      AND  [EDI], AX      //
    @LNXY16NOTRACEANDPEN:       //     Else ;
      ADD  EDI, EDX       //   Inc(Pt,AdXYPlus);
      SUB  ECX, EBX       //   Dec(dx, PasX)
      JNZ  @RepeatLNXY16ANDPEN  //   Until (dx=0);
    RET                   // Nota : AdXPlus a ici la valeur (AdXPlus + AdYPlus)

  @LINEOBL24BITSANDPEN: // Tracé de la ligne oblique
    MOV  EAX, Coul
    MOV  EDX, CoulTmp
    @RepeatLNXY24ANDPEN:
      ROL  MASQUE, 1      // Repeat
      JNC  @LNXY24NOTRACEANDPEN //   If PlotON
      AND  [EDI+0], AL    //
      AND  [EDI+1], AH    //
      AND  [EDI+2], DL    //
    @LNXY24NOTRACEANDPEN:       //     Else ;                             ----------
      ADD  EDI, AdXPlus   //   Inc(Pt,AdXYPlus);                    = 24 bits
      SUB  ECX, EBX       //   Dec(dx, PasX)
      JNZ  @RepeatLNXY24ANDPEN  //   Until (dx=0);
    RET                   // Nota : AdXPlus a ici la valeur (AdXPlus + AdYPlus) = EDX

  @LINEOBL32BITSANDPEN: // Tracé de la ligne horizontale
    MOV  EAX, Coul
    MOV  EDX, AdXPlus
    @RepeatLNXY32ANDPEN:
      ROL  MASQUE, 1      // Repeat
      JNC  @LNXY32NOTRACEANDPEN //   If PlotON
      AND  [EDI], EAX     //
    @LNXY32NOTRACEANDPEN:       //     Else ;
      ADD  EDI, EDX       //   Inc(Pt,AdXYPlus);
      SUB  ECX, EBX       //   Dec(dx, PasX)
      JNZ  @RepeatLNXY32COPYPEN  //   Until (dx=0);
    RET                   // Nota : AdXPlus a ici la valeur (AdXPlus + AdYPlus)

  @LINEOBL01BITSORPEN: // Tracé de la ligne oblique
    RET

  @LINEOBL04BITSORPEN: // Tracé de la ligne oblique
    RET

  @LINEOBL08BITSORPEN: // Tracé de la ligne oblique
    MOV  EAX, Coul
    MOV  EDX, AdXPlus
    @RepeatLNXY08ORPEN:
      ROL  MASQUE, 1      // Repeat
      JNC  @LNXY08NOTRACEORPEN //   If PlotON
      OR   [EDI], AL      //
    @LNXY08NOTRACEORPEN:       //     Else ;
      ADD  EDI, EDX       //   Inc(Pt,AdXYPlus);
      SUB  ECX, EBX       //   Dec(dx, PasX)
      JNZ  @RepeatLNXY08ORPEN  //   Until (dx=0);
    RET                   // Nota : AdXPlus a ici la valeur (AdXPlus + AdYPlus)

  @LINEOBL16BITSORPEN: // Tracé de la ligne oblique
    MOV  EAX, Coul
    MOV  EDX, AdXPlus
    @RepeatLNXY16ORPEN:
      ROL  MASQUE, 1      // Repeat
      JNC  @LNXY16NOTRACEORPEN //   If PlotON
      OR   [EDI], AX      //
    @LNXY16NOTRACEORPEN:       //     Else ;
      ADD  EDI, EDX       //   Inc(Pt,AdXYPlus);
      SUB  ECX, EBX       //   Dec(dx, PasX)
      JNZ  @RepeatLNXY16ORPEN  //   Until (dx=0);
    RET                   // Nota : AdXPlus a ici la valeur (AdXPlus + AdYPlus)

  @LINEOBL24BITSORPEN: // Tracé de la ligne oblique
    MOV  EAX, Coul
    MOV  EDX, CoulTmp
    @RepeatLNXY24ORPEN:
      ROL  MASQUE, 1      // Repeat
      JNC  @LNXY24NOTRACEORPEN //   If PlotON
      OR   [EDI+0], AL    //
      OR   [EDI+1], AH    //
      OR   [EDI+2], DL    //
    @LNXY24NOTRACEORPEN:       //     Else ;                             ----------
      ADD  EDI, AdXPlus   //   Inc(Pt,AdXYPlus);                    = 24 bits
      SUB  ECX, EBX       //   Dec(dx, PasX)
      JNZ  @RepeatLNXY24ORPEN  //   Until (dx=0);
    RET                   // Nota : AdXPlus a ici la valeur (AdXPlus + AdYPlus) = EDX

  @LINEOBL32BITSORPEN: // Tracé de la ligne horizontale
    MOV  EAX, Coul
    MOV  EDX, AdXPlus
    @RepeatLNXY32ORPEN:
      ROL  MASQUE, 1      // Repeat
      JNC  @LNXY32NOTRACEORPEN //   If PlotON
      OR   [EDI], EAX     //
    @LNXY32NOTRACEORPEN:       //     Else ;
      ADD  EDI, EDX       //   Inc(Pt,AdXYPlus);
      SUB  ECX, EBX       //   Dec(dx, PasX)
      JNZ  @RepeatLNXY32ORPEN  //   Until (dx=0);
    RET                   // Nota : AdXPlus a ici la valeur (AdXPlus + AdYPlus)

  @LINEOBL01BITSXORPEN: // Tracé de la ligne oblique
    RET

  @LINEOBL04BITSXORPEN: // Tracé de la ligne oblique
    RET

  @LINEOBL08BITSXORPEN: // Tracé de la ligne oblique
    MOV  EAX, Coul
    MOV  EDX, AdXPlus
    @RepeatLNXY08XORPEN:
      ROL  MASQUE, 1      // Repeat
      JNC  @LNXY08NOTRACEXORPEN //   If PlotON
      XOR  [EDI], AL      //
    @LNXY08NOTRACEXORPEN:       //     Else ;
      ADD  EDI, EDX       //   Inc(Pt,AdXYPlus);
      SUB  ECX, EBX       //   Dec(dx, PasX)
      JNZ  @RepeatLNXY08XORPEN  //   Until (dx=0);
    RET                   // Nota : AdXPlus a ici la valeur (AdXPlus + AdYPlus)

  @LINEOBL16BITSXORPEN: // Tracé de la ligne oblique
    MOV  EAX, Coul
    MOV  EDX, AdXPlus
    @RepeatLNXY16XORPEN:
      ROL  MASQUE, 1      // Repeat
      JNC  @LNXY16NOTRACEXORPEN //   If PlotON
      XOR  [EDI], AX      //
    @LNXY16NOTRACEXORPEN:       //     Else ;
      ADD  EDI, EDX       //   Inc(Pt,AdXYPlus);
      SUB  ECX, EBX       //   Dec(dx, PasX)
      JNZ  @RepeatLNXY16XORPEN  //   Until (dx=0);
    RET                   // Nota : AdXPlus a ici la valeur (AdXPlus + AdYPlus)

  @LINEOBL24BITSXORPEN: // Tracé de la ligne oblique
    MOV  EAX, Coul
    MOV  EDX, CoulTmp
    @RepeatLNXY24XORPEN:
      ROL  MASQUE, 1      // Repeat
      JNC  @LNXY24NOTRACEXORPEN //   If PlotON
      XOR   [EDI+0], AL    //
      XOR   [EDI+1], AH    //
      XOR   [EDI+2], DL    //
    @LNXY24NOTRACEXORPEN:       //     Else ;                             ----------
      ADD  EDI, AdXPlus   //   Inc(Pt,AdXYPlus);                    = 24 bits
      SUB  ECX, EBX       //   Dec(dx, PasX)
      JNZ  @RepeatLNXY24XORPEN  //   Until (dx=0);
    RET                   // Nota : AdXPlus a ici la valeur (AdXPlus + AdYPlus) = EDX

  @LINEOBL32BITSXORPEN: // Tracé de la ligne horizontale
    MOV  EAX, Coul
    MOV  EDX, AdXPlus
    @RepeatLNXY32XORPEN:
      ROL  MASQUE, 1      // Repeat
      JNC  @LNXY32NOTRACEXORPEN //   If PlotON
      XOR  [EDI], EAX     //
    @LNXY32NOTRACEXORPEN:       //     Else ;
      ADD  EDI, EDX       //   Inc(Pt,AdXYPlus);
      SUB  ECX, EBX       //   Dec(dx, PasX)
      JNZ  @RepeatLNXY32XORPEN  //   Until (dx=0);
    RET                   // Nota : AdXPlus a ici la valeur (AdXPlus + AdYPlus)

  @LINEOBL16BITSALPHAPEN:
  @LINEOBL24BITSALPHAPEN:
  @LINEOBL32BITSALPHAPEN:
    // Surprise ! Soon...
    RET

  // ########## CALLBACK FUNCTION ###########

  @LINEOBL01BITSUSER:
  @LINEOBL04BITSUSER:
  @LINEOBL08BITSUSER:
  @LINEOBL16BITSUSER:
  @LINEOBL24BITSUSER:
  @LINEOBL32BITSUSER:
    // Surprise ! Soon...
    RET

  //********* FIN DES SOUS ROUTINES DE TRACE *********

  @EXIT:
    MOV ESI, &ESI // Restauration de ESP
    MOV EDI, &EDI // Restauration de EBX
    MOV EBX, &EBX // Restauration de EBX
  End;
  Self.Mask := Masque;
  {$ELSE}

  // IMPLEMENTATION PASCALE ; Cette Implémentation supporte :
  //                           Le PenStyle (Dash, Dot ...)
  //                           Le GDIStyle (dernier point non tracé)
  //
  Inc(Seg.dx,PasX);
  Inc(Seg.dy,PasY);
  Pente := (Seg.dx*PasX)-(Seg.dy*PasY); // Différence des 2 delta x et y
  If (Pente>0) Then
  Begin // Droite orientée horizontale
    Courant :=(Seg.x1 - PasX) * $10000 + $8000;
    Pente   :=(Seg.dx * $10000) div Seg.dy * PasY;
    x       := Seg.x1 - PasX;
    Dec(Seg.dy, PasY);
    While (Seg.dy<>0) Do Begin // Est-on déjà à la dernière ligne ?
      Inc(Courant,Pente);   // Mise A Jour de la position courante en double précision
      dx := x;              // Préparation du calcul de l'écart
      x  := Courant shr 16; // On repasse en simple précision pour les coordonnées normales
      dx := x - dx;         // Calcul de la largeur en pixels de la ligne horizontale
      Hline;                // Traçage de la ligne Horizontale
      Dec(Seg.dy, PasY);    // Decrementation du compteur de boucle : une ligne tracée de +
    End;
    dx := Seg.x2 - x;       // Dernière ligne horizontale, ecourtée ou non d'un point
    If NotLast Then Dec(dx,PasX);
    If (dx<>0) Then HLine;

  End Else If (Pente<0) Then Begin // Droite orientée verticale
    Courant :=(Seg.y1 - PasY) * $10000 + $8000;
    Pente   :=(Seg.dy * $10000) div Seg.dx * PasX;
    y       := Seg.y1 - PasY;
    Dec(Seg.dx, PasX);
    While (Seg.dx<>0) Do Begin // Est-on déjà à la dernière ligne ?
      Inc(Courant,Pente);   // Mise A Jour de la position courante en double précision
      dy := y;              // Préparation du calcul de l'écart
      y  := Courant shr 16; // On repasse en simple précision pour les coordonnées normales
      dy := y - dy;         // Calcul de la largeur en pixels de la ligne Verticale
      Vline;                // Traçage de la ligne Verticale
      Dec(Seg.dx, PasX);    // Decrementation du compteur de boucle : une ligne tracée de +
    End;
    dy := Seg.y2 - y;       // Dernière ligne horizontale, ecourtée ou non d'un point
    If NotLast Then Dec(dy,PasY);
    If (dy<>0) Then VLine;
  End Else Begin // Droite en oblique
    AdXPlus := AdXPlus + AdYPlus;
    dx      := Seg.dx;
    If NotLast Then Dec(dx,PasX);
    If (dx<>0) Then DIAGOLine;
  End; // Fini !
  {$ENDIF}
End;


// ### EFFETS SPECIAUX ###################################

procedure TDIBUltra.NoAlpha;
Begin
  FreeMem(Alpha);
End;

procedure TDIBUltra.MakeTransparent(ColorIndex : Byte);
Begin
  If (PixelFormat>DUpf8) Then Exit;
  DIBStatus := DIBStatus + [DUtTransparent];
  DIBTransp := ColorIndex;
End;

procedure TDIBUltra.MakeOpaque;
Begin
  DIBStatus := DIBStatus - [DUtTransparent];
End;

{$IFDEF NEVER_DEFINED}
FORMAT DE COMPRESSION DU MASQUE ALPHA MULTICHANEL.
  Format simpliste pour privilégier la vitesse de décompression :
  champs de Word représentant pour chacun :
    Octet 1 : Valeur de la densité (0-32 ; 0 transparence totale ; 32 opacité complète)
    Octet 2 : Nombre de répétition (de 1 à 255)
  Une fin de ligne (EOL) est signalée par un code de 0.
  Lorsque deux EOL se suivent, cela indique un EOF (End Of File)
  Lorsqu''une ligne ne se termine plus que par un niveau total de transparence,
  on émet de suite un EOL à la place.
{$ENDIF}
procedure TDIBUltra.SetAlphaFile(Const MaskFile : String ; Num , Delay : Integer);
var Mask : TDIBUltra;
Begin
  If (Not FileExists(MaskFile)) Then Exception.Create('Alpha Mask File Invalid.');
  Mask := TDIBUltra.CreateFromFile(MaskFile);
    SetAlphaMask( Mask, Num , Delay);
  Mask.Free;
End;


procedure TDIBUltra.SetAlphaMask( Mask : TDIBUltra ; Num, Delay : Integer);
type
  TWordArray = Array [0..0] of Word;
var
  // Général
  StTo     : TMemoryStream;
  Header   : TAlphaMaskHeader;
  // Asm
  Src      : ^TWordArray;
  Dst, Lg  : Integer;
  ESI, EDI     : Integer;
  // Compression
  i,j      : Integer;
  Val      : Word;
  Rep      : Word;
  Pxl      : ^Byte;
  Last0    : Integer;

Begin
  // Solution intermédiaire en attendant l'animation
  If (Num<>1) Then Raise Exception.Create('AlphaBlit ne supporte pas encore l''animation. (Num doit être = 1)');

  If (Mask.PixelFormat<>DUpf8) Then Raise Exception.Create('Le masque doit être une image en 256 couleurs !');
  If (Mask.width  <> DIBWidth ) AND
     (Mask.height <> DIBHeight) Then Exception.Create('L''image du masque doit être de même dimensions que le motif !');

  // Solution intermédiaire en attendant l'animation
  If (Alpha<>nil) Then FreeMem(Alpha); // On élimine l'ancien masque

  StTo := TMemoryStream.Create;
  // COMPRESSION DU MASQUE
  For i := 0 to (Mask.Height-1) Do
  Begin
    j     := Mask.Width - 1;
    Pxl   := Mask.ScanLine[i];
    Last0 := 0;
    While True Do Begin
      Val := Pxl^ AND $F8; Rep := 2; Dec(j); Inc(Pxl); // Lecture du pixel du masque
      While ((Val=(Pxl^ AND $F8)) AND (j>0) AND (Rep<256)) Do // Recherche de répétition
        Begin Inc(Rep); Inc(Pxl); Dec(j) End;
      // Ecriture d(u/es) Pixel(s) compressé(s)
      Dec(Rep); // On retire les dernier lus
      If (Val=0) Then Begin If (Last0=0) Then Last0 := StTo.Position; End// Activer Last0 //:-)
                 Else Last0 := 0;                                        // Annuler Last0 //:-(
      Val := (Val shl 5) OR Rep;
      StTo.WriteBuffer(Val, sizeOf(Val));
      If (j=0) Then // Fin de ligne
      Begin
        If (Last0<>0) Then Begin    // On gagne des octets
          StTo.Position := Last0-sizeOf(Val); // Vérifions que l'octet d'avant n'est pas un EOL
          StTo.ReadBuffer(Val,sizeOf(Val));
          If (Val=0) Then Begin
            Val := $0001; // Un pixel nul entre les deux $00 pour éviter une méprise avec un EOF
            StTo.WriteBuffer(Val,sizeOf(Val));
            // Goto Sortie
          End;
        End;
        Val := $0000; StTo.WriteBuffer(Val,sizeOf(Val));
        Break
      End;
    End; // On passe au pixels suivants
  End;
  StTo.WriteBuffer(Val,sizeOf(Val)); {WRITE EOL <=> EOF}
  // FIN DE COMPRESSION
  // Mise à jour du Masque Header
  If (StTo.Position>= $10000) Then Raise Exception.Create('TDIBUltra ne gère pas les masques Alpha faisant + de 65Ko après compression !');
  Header.NbMask := 1;
  Header.TotalSz:= SizeOf(TAlphaMaskHeader) + StTo.Position ; // Valable si on n'a qu'un seul masque
  Header.Info[1].Periode := Delay; // Image permanente
  Header.Info[1].Size    := Word(StTo.Position); // Sz doit être inférieur à $10000 (65 Ko)
  // C'est bon, on peut (ré)allouer la structure Alpha :
  GetMem(Alpha, Header.TotalSz);
  DIBStatus := DIBStatus + [DUtAlpha];
  // Transfert des informations [ Header + Masque(s) compressé(s) ]
  Dst := Integer(Alpha);
  ASM
    MOV &ESI, ESI ; MOV &EDI, EDI // Sauvegarde

    MOV EDI, Dst // En destination
    MOV ECX, I(SizeOf(TAlphaMaskHeader))
    LEA ESI, [Header]
  @TransfertHeader:
      MOV AL, [ESI] ; MOV [EDI], AL
      INC ESI ; INC EDI
      LOOP @TransfertHeader
    MOV ECX, Lg
    MOV ESI, Src

    MOV ESI, &ESI ; MOV EDI, &EDI // Sauvegarde
  END;

  Src := StTo.Memory;
  For i := 0 to (StTo.Position div 2) Do
    Alpha.Field[i] := Src^[i];
End;

{$INCLUDE DIBFX.pas} // Inclusion directe des routines d'effets spéciaux

end.

