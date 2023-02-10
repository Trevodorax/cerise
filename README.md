# cerise

This is the implementation of the barycentric triangle filling algorithm on Linux using Assembler NASM X86-64.  


# Pseudo-code : 

On détermine si le triangle est direct ou indirect grâce au déterminant.

Si le triangle est un triangle direct :
si le point concerné est à droite de tous ses segments
alors il est à l'intérieur du triangle et on le dessine.
Si le triangle est un triangle indirect :
si le point concerné est à gauche de tous ses segments
alors il est à l'intérieur du triangle et on le dessine.

