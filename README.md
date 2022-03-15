# Read_BDF_Matlab
Script para leer archivos .bdf (Biosemi) que lee todos los eventos (a diferencia de EEGLab y/o Fieldtrip)

El EEG del laboratorio de Neurosistemas es marca Biosemi. Los archivos de datos crados por Biosemi están en un formato propietario llamado biosemi data format (.bdf).
Tanto EEGLab como Fieldtrip pueden leer archivos .bdf, pero, por razones desconocidas para mi, no siempre leen todos eventos (TTLs) generados por diversos programas 
como Experiment Builder o Stim_Only (JIE). 
Esta incapacidad de leer todos los eventos puede llevar a un error en el análisis ya que, por ejemplo, no se detectan todos los estímulos.
Para solucionar este problema se puede usar una la función sload que es parte del toolbox BioSig.

Para más info sobre Biosig
http://biosig.sourceforge.net/
