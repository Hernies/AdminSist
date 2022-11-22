Proyecto de administración de sistemas informáticos
Objetivos
El objetivo de este proyecto práctico de desarrollo en pareja, aunque también puede realizarse de forma individual, es revisar de forma aplicada algunos de los conceptos estudiados en la parte teórica de la asignatura, concretamente, en la parte de administración de sistemas Linux, tales como:
La gestión de usuarios y grupos, así como de los permisos de acceso de estos a los recursos.
La gestión de paquetes.
La administración de los dispositivos de almacenamiento, incluyendo la gestión de volúmenes, la creación de sistemas de ficheros y las operaciones de montaje.
La administración de un servicio de red, concretamente, NFS.
Los fundamentos de las técnicas usadas para automatizar la administración.
La programación de scripts.
Planteamiento general
El proyecto consiste en el desarrollo de scripts de administración, uno por cada una de las siguientes 5 fases de las que consta el proyecto:
crear_usuarios: gestión de usuarios.
configurar_almacenamiento: administración de volúmenes.
nfs_servidor: configuración de la parte servidora de NFS.
nfs_cliente: configuración de la parte cliente de NFS.
maestro: automatización de la administración de máquinas remotas, ejecutando de forma remota los scripts desarrollados en las fases previas (un Ansible de andar por casa).
Cada fase se calificará con 2 puntos y pueden realizarse en cualquier orden (de hecho, incluso se podría realizar la última fase antes de las demás, como se verá en el enunciado de la misma), exceptuando las fases vinculadas con NFS que deberían realizarse en el orden indicado (no se tendrá en cuenta una entrega de la cuarta fase si no se hace también una de la tercera). Así, por ejemplo, se podrían entregar solo los tres últimos scripts, pudiendo llegar a obtener una calificación de 6 puntos.
Nótese que los 3 primeros scripts se pueden desarrollar en un único equipo, mientras que para los 2 últimos sería conveniente disponer de, al menos, dos equipos.

Plataforma de desarrollo
La distribución de Linux seleccionada para la práctica es Ubuntu 22.04. Si se plantea desarrollarla en otra distribución, puede hacerlo, pero debería probar el código desarrollado en la distribución seleccionada ya que será la usada para evaluar la práctica.
Para el desarrollo de la práctica puede usar máquinas reales o virtuales usando, por ejemplo, Virtualbox. En ese último caso, puede optar por gestionar manualmente las máquinas virtuales o usar una herramienta como Vagrant para administrarlas de una manera más automática.

Para poder probar el segundo script, el equipo debería disponer de varios discos, aunque bastaría con varias particiones libres. En el caso de usar una máquina virtual, estando esta parada, puede añadirle nuevos discos.

Con respecto a las dos últimas fases, convendría probarlas en, al menos, 2 equipos. Si usa un entorno de virtualización, puede instalar Ubuntu 22.04 en un equipo y luego clonarlo, estableciendo una conectividad que permita a esos equipos comunicarse entre sí y salir a Internet (téngase en cuenta que los scripts deben instalar paquetes).

En el caso de Virtualbox, para ahorrar el gasto de disco, puede usar una clonación enlazada especificando en la política de dirección de MAC la opción de generar nuevas direcciones MAC para todas las interfaces. En cuanto a la conectividad, se recomienda configurar la interfaz de red con la modalidad red NAT, que cumple los requisitos de conectividad especificados previamente.

Consideraciones generales sobre la programación de los scripts
A continuación, se exponen algunas pautas sobre la programación de los scripts planteados en este proyecto práctico:
No deben ser interactivos: no pueden quedarse a la espera de alguna entrada de teclado.
Solo deben escribir por la salida estándar lo especificado en el enunciado, aunque sí se puede usar la salida de error a discreción.
Deben instalar todos los paquetes que se requieran. Se asumirá que ya están instalados aquellos que aparecen como tal en una instalación por defecto de Ubuntu 22.04.
No realizarán la operación apt update.
Para evitar desconfigurar la máquina de pruebas debido a un error de programación, la funcionalidad que se plantea no incluye operaciones destructivas tales como borrar ficheros, eliminar usuarios o grupos, desinstalar paquetes o borrar volúmenes.
Con respecto a la gestión de errores en los scripts que se resuelven de forma local (los tres primeros), se ha optado por un tratamiento por anticipado: antes de realizar las operaciones para las que está concebido, el script deberá comprobar a priori todas las condiciones de error, no realizando ninguna labor si falla esa comprobación. Esta técnica reduce la posibilidad de que se produzcan errores durante la ejecución del script. Téngase en cuenta que, sin esa comprobación a priori, esos errores en medio de la operación normalmente requerirán deshacer algunas de las acciones realizadas previamente para evitar que el sistema se quede en un estado inconsistente (en la primera fase, por ejemplo, si el tercer usuario que se quiere crear ya existe, habría que abortar la operación pero eliminando antes el grupo y los dos usuarios previamente creados). Eso es precisamente lo que se pretendía evitar en el punto anterior.
En cualquier caso, aunque sea poco probable, alguna de la condiciones comprobadas podría dejar de cumplirse en el pequeño intervalo de tiempo que transcurre desde que se comprueba hasta que se realiza la operación asociada, produciéndose un error (con mala suerte, en el ejemplo, justo después de comprobar que no había ningún usuario repetido, alguien crea un usuario duplicado). En ese caso, para simplificar la práctica, bastará con terminar el script con el valor de retorno que considere oportuno, ya que esa funcionalidad de tratamiento de errores sobrevenidos no se probará en la evaluación de la práctica, no siendo necesario deshacer el trabajo ya realizado, aunque esto pueda dejar el sistema en un estado incoherente.
Con respecto al tratamiento de errores en los dos últimos scripts, dado que su funcionamiento depende de otros nodos, en la sección dedicada a cada uno se explicará cómo se debe proceder.
Consideraciones generales sobre la ejecución de los scripts
A continuación, se expresan algunas pautas sobre la ejecución de los scripts:
Al no permitirse la ejecución interactiva, la ejecución de los scripts no debe requerir ningún tipo de contraseña.
Se ejecutarán en la cuenta del usuario creado por defecto en la instalación de la distribución: los 4 primeros scripts usando sudo. Se asume, por tanto, que ese usuario pertenecerá al grupo que permite ejecutar sudo.
Se configurará el fichero /etc/sudoers para que no requiera contraseña (esa labor no se hace dentro del script sino manualmente antes de empezar a desarrollar la práctica). En Ubuntu 22.04, habría que realizar las siguientes modificaciones en el fichero:
# Allow members of group sudo to execute any command
#%sudo  ALL=(ALL:ALL) ALL            # comentar esta línea
%sudo   ALL=(ALL:ALL) NOPASSWD:ALL   # y añadir esta
En el caso del último script, se asume que en todas las máquinas el usuario por defecto tiene el mismo nombre y está habilitado para sudo sin contraseña.
Dado que este último script se basa en el uso de ssh y, además, no se permite la ejecución interactiva, hay que asegurarse de que está instalado en todas las máquinas usando un modo de operación sin contraseñas (esa labor no se hace dentro del script sino manualmente antes de empezar a desarrollar la quinta fase). Para ello, puede ejecutar la siguiente secuencia:
ssh-keygen # generar las claves dejando vacía la passphrase
ssh-copy-id 10.0.2.4 # copiar las claves a la máquina remota usando la contraseña
Este último script se ejecutará sin sudo, pero sí lo usará internamente en la ejecución de los scripts remotos, tal como se explicará cuando se presente la última fase.
Primera fase
Se pretende crear las cuentas de un conjunto de usuarios relacionados entre sí (por ejemplo, porque participan en un mismo proyecto). Para facilitar la compartición de ficheros entre ellos, se creará un grupo de usuarios al que todos pertenecerán como grupo secundario o suplementario (es decir, cada usuario tendrá como grupo primario el creado por defecto con el mismo nombre que el usuario, pero, además estará asociado a ese grupo secundario). Asimismo, se creará un directorio en /srv con el nombre de ese grupo secundario donde se almacenarán los ficheros que quieran compartir.
El formato del mandato es el siguiente:

crear_usuarios grupo usuario1 usuario2...
En caso de funcionamiento correcto, el script debe imprimir por la salida estándar las contraseñas asociadas a las cuentas de usuario creadas con el siguiente formato:
usuario1:contraseña
usuario2:contraseña
...................
La funcionalidad del script es:
Como se explicó previamente, se debe realizar un control de errores antes de realizar ninguna operación. En ese control se deben verificar las siguientes condiciones de error que provocarán que el script termine inmediatamente retornando un código de error:
Se debe estar ejecutando como superusuario (recuerde que, como se indicó previamente, se debe ejecutar con sudo), devolviendo un 1 en caso contrario. Esa comprobación ya está incluida en el script proporcionado como material de apoyo.
El número de argumentos debe de ser correcto, devolviendo un 2 en caso contrario.
No debe existir un fichero o directorio /srv/grupo, devolviendo un 3 en caso contrario.
No debe existir ese grupo, devolviendo un 4 en caso contrario. Hay distintas formas de comprobarlo. Una posibilidad es el uso del mandato getent.
No debe existir ninguno de los usuarios especificados, devolviendo un 5 en caso contrario. Hay distintas formas de comprobarlo. Una posibilidad es el uso del mandato getent.
Una vez verificada la falta de errores, se procederá con las operaciones asociadas a este script:
Creación del grupo secundario. Puede usar el mandato groupadd ya que está disponible en todas las distribuciones.
Creación de los usuarios indicados. Puede usar el mandato useradd especificando que el shell sea el bash, que se cree el directorio home e incluyéndolo en el grupo secundario indicado.
Con respecto a la gestión de la contraseña, debe tener en cuenta (por defecto, useradd crea una cuenta bloqueada):
Se debe generar una aleatoria para cada usuario. Hay numerosas formas de generar una cadena de caracteres aleatoria (aquí hay varios ejemplos). Recuerde que, si opta por un mandato que no está instalado en Ubuntu 22.04, deberá proceder con la instalación.
Una vez obtenida, además de imprimirla por la salida estándar junto con el nombre del usuario separados por el carácter dos puntos, debe asociarla con el usuario. Una forma posible de hacerlo es mediante el mandato chpasswd. También puede hacerlo en el propio mandato useradd con la opción -p, pero tenga en cuenta que en ese caso la contraseña debe estar ya cifrada.
Aunque no se evaluará estrictamente este aspecto, un reto que se presenta en la realización de un script que gestione contraseñas es cómo asegurarse de que las contraseñas no son visibles de alguna forma mientras se ejecuta el script. Así, por ejemplo, si la contraseña aparece como argumento de un mandato, el usuario maligno podría tener acceso a la misma haciendo un ps justo en el momento que se ejecuta el mandato, a no ser que se trate de un mandato interno del shell como, por ejemplo, echo.
Hay que crear el directorio asociado al grupo de usuarios (/srv/grupo), que deberá tener las siguientes características:
El dueño será el primer usuario y estará asociado al grupo secundario indicado.
Permitirá acceso y lectura a todos los usuarios, pero solo podrán crear y borrar entradas el dueño y los usuarios asociados al grupo secundario especificado.
El directorio será configurado de manera que todos los ficheros que se creen en el mismo estén asociados automáticamente con el grupo secundario y no con el grupo del usuario que crea el fichero, facilitando la compartición, como se verá en el ejemplo que se muestra acto seguido. Una pista sobre esta funcionalidad: revise todas las aplicaciones de los bits SETUID/SETGID.
A continuación, se muestra un ejemplo de la ejecución de este mandato ilustrando cuál debe ser su comportamiento:
fperez@ubuntu22:~/ASI/proyecto$ sudo ./crear_usuarios.sh proyectoX usu1 usu2 usu3
usu1:ijdyhing
usu2:deadWokPi
usu3:vemNeicNub
fperez@ubuntu22:~/ASI/proyecto$ ls /srv
proyectoX
fperez@ubuntu22:~/ASI/proyecto$ su - usu2
Contraseña: 
usu2@ubuntu22:~$ echo hola > /srv/proyectoX/fichero
usu2@ubuntu22:~$ ls -l /srv/proyectoX/fichero # pertenece al grupo proyecto X, no al grupo usu2 
-rw-rw-r-- 1 usu2 proyectoX 5 nov 11 06:16 /srv/proyectoX/fichero
usu2@ubuntu22:~$ su - usu3
Contraseña: 
usu3@ubuntu22:~$ echo adios >> /srv/proyectoX/fichero
usu3@ubuntu22:~$ su - fperez
Contraseña: 
fperez@ubuntu22:~$ echo buenas >> /srv/proyectoX/fichero
-bash: /srv/proyectoX/fichero: Permiso denegado
fperez@ubuntu22:~$ cat /srv/proyectoX/fichero
hola
adios
Segunda fase
El objetivo de esta fase es crear un espacio de almacenamiento flexible basado en volúmenes que podría ser usado como soporte por una herramienta o por un grupo de usuarios. Para ello, se creará un grupo de volúmenes (VG) sobre una colección de discos o particiones (PVs), generando el conjunto de volúmenes lógicos (LVs) solicitado que se montarán en los directorios indicados, los cuales se crearán si no existen
El formato del mandato es un poco complicado ya que, además del nombre del grupo de volúmenes, recibe como parámetros la colección de discos o particiones que se tomarán como base del grupo de volúmenes y el conjunto de directorios sobre los que se montarán los volúmenes lógicos pedidos, así como el porcentaje del total que ocupará cada volumen lógico.

configurar_almacenamiento.sh nombreVG num_discos disco1 disco2... num_LVs porcentaje1 directorio_montaje1 porcentaje2 directorio_montaje2...
El script no debe escribir nada por la salida estándar.
La funcionalidad del script es la siguiente:

Como se explicó previamente, se debe realizar un control de errores antes de realizar ninguna operación. En ese control se deben verificar las siguientes condiciones de error que provocarán que el script termine inmediatamente retornando un código de error:
Se debe estar ejecutando como superusuario (recuerde que, como se indicó previamente, se debe ejecutar con sudo), devolviendo un 1 en caso contrario. Esa comprobación ya está incluida en el script proporcionado como material de apoyo.
El número de argumentos debe de ser correcto y deben ser numéricos los argumentos correspondientes al número de discos/particiones, al número de LVs y a los porcentajes que indican el tamaño de cada LV, devolviendo un 2 en caso contrario. Dada la laboriosidad de esta comprobación ya está incluida en el script proporcionado como material de apoyo.
Los porcentajes no pueden sumar más de 100, retornando un error con valor 3 en caso contrario. Esta funcionalidad ya aparece en el script dado como material de apoyo.
Se debe comprobar que los discos/particiones recibidos como argumentos corresponden realmente a dispositivos de bloques, devolviendo un 4 en caso contrario. Una posible forma de comprobarlo es usar el mandato lsblk.
Hay que asegurarse de que los directorios de montaje o bien no existen, en cuyo caso habrá que crearlos más adelante, o bien existen y son directorios, devolviendo un 5 en caso contrario.
La última comprobación es que el grupo de volúmenes (VG) especificado no exista previamente, retornando un 7 en caso contrario. Para poder comprobarlo, es necesario tener instalado previamente el paquete con la funcionalidad de gestión de volúmenes (lvm2).
Una vez comprobado que no existen errores a priori, se procede a implementar la funcionalidad del script:
Se debe crear el VG que englobe todos los dispositivos involucrados. Recuerde que el mandato requerido (vgcreate) crea automáticamente los volúmenes físicos PVs, no siendo necesario realizar los respectivos pvcreate.
Por cada LV, se deben realizar las siguientes operaciones:
Crear el directorio de montaje indicado en caso de que no exista.
Crear el volumen lógico con el tamaño especificado. No es necesario darle un nombre explícito al LV. En caso de no hacerlo, obtendrán sucesivamente los nombres lvol0, lvol1...
Crear un sistema de ficheros en el LV.
Establecer que ese LV se monte en el directorio indicado cada vez que arranque la máquina.
Realizar el montaje.
A continuación, se muestra un ejemplo de la ejecución de este mandato ilustrando cuál debe ser su comportamiento:
fperez@ubuntu22:~/ASI/proyecto$ ls /mnt /mnt2 /mnt3
ls: no se puede acceder a '/mnt2': No existe el archivo o el directorio
ls: no se puede acceder a '/mnt3': No existe el archivo o el directorio
/mnt:
fperez@ubuntu22:~/ASI/proyecto$ sudo ./configurar_almacenamiento.sh VG3 2 /dev/sdb /dev/sdc 3 33 /mnt  33 /mnt2 34 /mnt3
fperez@ubuntu22:~/ASI/proyecto$ sudo lvs
  LV    VG  Attr       LSize  Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  lvol0 VG3 -wi-ao---- 80,00m
  lvol1 VG3 -wi-ao---- 80,00m
  lvol2 VG3 -wi-ao---- 84,00m
fperez@ubuntu22:~/ASI/proyecto$ mount | grep \/mnt
/dev/mapper/VG3-lvol0 on /mnt type ext2 (rw,relatime)
/dev/mapper/VG3-lvol1 on /mnt2 type ext2 (rw,relatime)
/dev/mapper/VG3-lvol2 on /mnt3 type ext2 (rw,relatime)
Tercera fase
El objetivo de esta fase es crear un script que realice la configuración de un servidor NFS acorde a los parámetros especificados que indican qué directorios se exportan, con qué permisos (rw o ro) y a qué máquinas.
El formato del mandato es el siguiente:

nfs_servidor.sh hosts_permitidos1 permisos1 directorio_exportado1 hosts_permitidos2 permisos2 directorio_exportado2......
Se va a considerar que, si en el argumento correspondiente a las máquinas a las que se les permite importar un directorio aparece un 0, se estará solicitando habilitar acceso universal a ese directorio.
El script no debe escribir nada por la salida estándar.

La funcionalidad del script es la siguiente:

Como se explicó previamente, se debe realizar un control de errores antes de realizar ninguna operación. En ese control se deben verificar las siguientes condiciones de error que provocarán que el script termine inmediatamente retornando un código de error:
Se debe estar ejecutando como superusuario (recuerde que, como se indicó previamente, se debe ejecutar con sudo), devolviendo un 1 en caso contrario. Esa comprobación ya está incluida en el script proporcionado como material de apoyo.
El número de argumentos debe de ser correcto (múltiplo de 3) y los permisos especificados deben corresponder a los valores rw o ro, devolviendo un 2 en caso contrario.
Se debe comprobar que los directorios exportados existen, retornando un error con valor 3 en caso contrario.
Una vez comprobado que no existen errores a priori, se procede a implementar la funcionalidad del script:
En primer lugar, hay que asegurarse de tener instalado el paquete que contiene la funcionalidad de servidor de NFS.
A continuación, por cada directorio exportado, se debe añadir la línea correspondiente al fichero donde se definen las exportaciones, tratando el caso especial de que aparezca un 0 en el campo correspondiente a los equipos permitidos, que implica un acceso universal. Solo es necesario que se especifique los permisos: las demás opciones pueden tomar los valores por defecto.
Por último, hay que ejecutar adecuadamente el mandato exportfs para actualizarlas.
A continuación, se muestra un ejemplo de la ejecución de este mandato ilustrando cuál debe ser su comportamiento:
fperez@ubuntu22:~/ASI/proyecto$ sudo ./nfs_servidor.sh 10.0.2.0/24 rw /srv 0 ro /mnt
fperez@ubuntu22:~/ASI/proyecto$ sudo exportfs -v # con los permisos especificados y las opciones por defecto
/srv          	10.0.2.0/24(sync,wdelay,hide,no_subtree_check,sec=sys,rw,secure,root_squash,no_all_squash)
/mnt          	<world>(sync,wdelay,hide,no_subtree_check,sec=sys,ro,secure,root_squash,no_all_squash)
Cuarta fase
El objetivo de esta fase es crear un script que realice la configuración de un cliente NFS acorde a los parámetros especificados que indican qué directorios se importan, de qué servidores y en qué directorios locales se montan.
El formato del mandato es el siguiente:

nfs_cliente.sh servidor1 directorio_importado1 directorio_montaje1 servidor2 directorio_importado2 directorio_montaje2...
El script no debe escribir nada por la salida estándar.

Nótese que este es el primer script cuyo resultado depende del estado de otro nodo. No se va a permitir que este script ejecute operaciones sobre el nodo remoto con ssh para evitar relaciones complejas entre las máquinas (téngase en cuenta que, si permitimos que este script haga un ssh sobre el nodo que actúa de servidor NFS, al abordar la última fase tendríamos una relación de tres: el nodo maestro realiza un ssh al nodo cliente NFS que, a su vez, lleva a cabo un ssh al nodo servidor NFS).

La funcionalidad del script es la siguiente:

En este script, solo se puede realizar un control de errores anticipado para condiciones locales:
Se debe estar ejecutando como superusuario (recuerde que, como se indicó previamente, se debe ejecutar con sudo), devolviendo un 1 en caso contrario. Esa comprobación ya está incluida en el script proporcionado como material de apoyo.
El número de argumentos debe de ser correcto (múltiplo de 3), devolviendo un 2 en caso contrario.
Hay que asegurarse de que los directorios de montaje o bien no existen, en cuyo caso habrá que crearlos más adelante, o bien existen y son directorios, devolviendo un 3 en caso contrario.
Puede producirse un error si el equipo especificado (el servidor NFS) no está accesible o no exporta al cliente el directorio especificado. En este caso, no se realiza una estrategia anticipada, sino que se detectará en el propio mandato mount, evitando cualquier cambio de estado vinculado con ese directorio importado y terminando el script con un valor de retorno 4 sin procesar el resto de los directorios importados.
Con respecto a la funcionalidad del script:
En primer lugar, hay que asegurarse de tener instalado el paquete que contiene la funcionalidad de cliente de NFS.
A continuación, por cada directorio importado, debe establecerse que se monte sobre el directorio local especificado, que se creará si no existe, el directorio remoto indicado cada vez que arranque la máquina y, además, realizar el montaje. Recuerde que es en ese punto donde se detectarán los errores vinculados con el nodo remoto.
A continuación, se muestra un ejemplo de la ejecución de este mandato ilustrando cuál debe ser su comportamiento. Nótese que en este caso hay dos máquinas involucradas en la prueba, estando la máquina 10.0.2.4 configurada como servidor NFS siguiendo el ejemplo mostrado en la fase previa.
ls /mnt /mnt4
ls: no se puede acceder a '/mnt4': No existe el archivo o el directorio
/mnt:
fperez@ubuntu22:~/ASI/proyecto$ sudo ./nfs_cliente.sh 10.0.2.4 /srv /mnt 10.0.2.4 /mnt /mnt4
fperez@ubuntu22:~/ASI/proyecto$ mount | grep \/mnt
10.0.2.4:/srv on /mnt type nfs4 (rw,relatime,vers=4.2,rsize=262144,wsize=262144,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,clientaddr=10.0.2.15,local_lock=none,addr=10.0.2.4)
10.0.2.4:/mnt on /mnt4 type nfs4 (rw,relatime,vers=4.2,rsize=262144,wsize=262144,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,clientaddr=10.0.2.15,local_lock=none,addr=10.0.2.4)
Quinta fase
Esta fase es la culminación del proyecto creando un rudimento de una herramienta de automatización de la administración, que, de manera similar a Ansible, tenga un modo de operación con un nodo maestro de control que va copiando (scp) a los nodos gestionados (al directorio /tmp de cada nodo remoto) y ejecutando de forma remota (ssh) los scripts de configuración especificados. Recuerde que para probar esta fase se requieren, al menos, dos equipos configurados previamente para que puedan trabajar con ssh sin contraseñas.
Nótese que se proporciona un script de configuración muy sencillo (kernel_log.sh) para depurar esta fase e incluso poder realizarla sin haber hecho las fases previas.

El formato del mandato es el siguiente:

maestro.sh fich_config
El formato del fichero de configuración es el que se muestra a continuación:
# comentario y a continuación una línea en blanco

NOMBRE_PRUEBA1 HOST1 FICH_SALIDA1 MANDATO1 ARG1 ARG2...
NOMBRE_PRUEBA2 HOST2 FICH_SALIDA2 MANDATO2 ARG1 ARG2...
Por ejemplo:
# máquina apagada
KERNEL_LOG 10.0.2.33 /tmp/kerlog-33.txt kernel_log.sh 12

# no pasa parámetro
KERNEL_LOG 10.0.2.4 /tmp/kerlog-4.txt kernel_log.sh

# OK
KERNEL_LOG 10.0.2.4 /tmp/kerlog-4.txt kernel_log.sh 15

    # OK
KERNEL_LOG 10.0.2.15 /tmp/kerlog-15.txt kernel_log.sh 10
Con respecto a la salida estándar, debe tener el siguiente formato:
EJECUTANDO NOMBRE_PRUEBA1 EN HOST1
RESULTADO RES SALIDA EN FICH_SALIDA1
EJECUTANDO NOMBRE_PRUEBA2 EN HOST2
RESULTADO RES SALIDA EN FICH_SALIDA2
.....................................
donde RES puede ser: OK, UNREACHABLE o ERROR=N siendo N el valor distinto de 0 devuelto por el script de configuración.
Este es el resultado para el ejemplo planteado:

EJECUTANDO KERNEL_LOG EN 10.0.2.33
RESULTADO UNREACHABLE SALIDA EN /tmp/kerlog-33.txt
EJECUTANDO KERNEL_LOG EN 10.0.2.4
RESULTADO ERROR=2 SALIDA EN /tmp/kerlog-4.txt
EJECUTANDO KERNEL_LOG EN 10.0.2.4
RESULTADO OK SALIDA EN /tmp/kerlog-4.txt
EJECUTANDO KERNEL_LOG EN 10.0.2.15
RESULTADO OK SALIDA EN /tmp/kerlog-15.txt
La funcionalidad del script es la siguiente:
Se ejecutará sin sudo en el nodo maestro de control, pero en la cuenta que está asociada a sudo en los nodos remotos.
Sí usará sudo para ejecutar el mandato remoto:
# la opción -n impide que ssh lea la entrada estándar
ssh -n $HOST sudo ...
Copiará los sucesivos scripts de configuración en el directorio /tmp de la máquina remota, no siendo necesario borrar ese fichero remoto al concluir la ejecución de ese script (seguimos con la política de evitar acciones destructivas por si las moscas).
Con respecto al control de errores en la línea de mandatos, debe verificarse que se recibe un único argumento y que este es un fichero regular que el usuario puede leer. En caso contrario, el script debe terminar devolviendo un 1.
En cuanto el control de errores en el procesado del fichero de configuración, si hay un error en la especificación de una línea, se mostrará un mensaje de error por la salida de error y se pasará a procesar la siguiente línea (el script continuará y seguirá terminando con un valor 0). Nótese que en caso de error no debería ejecutarse el scp ni aparecer en la salida EJECUTANDO.... Hay que controlar los siguientes errores:
Una línea debe incluir el número de campos pertinente.
Debe existir y ser accesible el fichero especificado como mandato.
El fichero indicado para recoger la salida, en caso de existir, debería ser modificable por el usuario (por ejemplo, /etc/passwd no lo sería) que ejecuta el script maestro (recuerde que se ejecuta sin sudo) pero no ser un directorio (por ejemplo, /tmp). En caso de no existir, debería comprobarse que el usuario puede crearlo y, en caso negativo (por ejemplo, /noexiste), no realizar el scp, imprimir el mensaje de error y pasar a la siguiente línea.
Recuerde que no se consideran como error las líneas vacías (o llenas de espacios y/o tabuladores) ni aquellas cuyo primer carácter distinto del espacio sea un #.
Por lo que se refiere al procesado de una línea válida, requerirá la copia del mandato al directorio /tmp remoto. A continuación, si no ha habido un error, se ejecutará el mandato remoto recogiendo su salida estándar y su estado de terminación. Por último, se imprimirá el resumen del resultado diferenciando entre UNREACHABLE, si falló el scp o el ssh devolvió el valor 255, OK, en caso de que el script remoto termine satisfactoriamente, o ERROR=N, si terminó con un valor distinto de 0.
A continuación, se muestra un ejemplo de fichero de configuración:
# máquina apagada
KERNEL_LOG 10.0.2.33 /tmp/kerlog-33.txt kernel_log.sh
# no pasa parámetro
KERNEL_LOG 10.0.2.4 /tmp/kerlog-4.txt kernel_log.sh
KERNEL_LOG 10.0.2.4 /tmp/kerlog-4.txt kernel_log.sh 15
KERNEL_LOG 10.0.2.15 /tmp/kerlog-15.txt kernel_log.sh 10

CREA_USUARIOS 10.0.2.4 /tmp/usu_contra-4 crear_usuarios.sh new-project user1 user2 user3
CREA_USUARIOS 10.0.2.15 /tmp/usu_contra-15 crear_usuarios.sh new-project user1 user2 user3

CREA_ALMACENAMIENTO 10.0.2.15 /dev/null configurar_almacenamiento.sh VG3 2 /dev/sdb /dev/sdc 3 33 /mnt  33 /mnt2 34 /mnt3

NFS_SRV 10.0.2.4 /dev/null nfs_servidor.sh 10.0.2.0/24 rw /srv 0 ro /mnt
NFS_CLNT 10.0.2.15 /dev/null nfs_cliente.sh 10.0.2.4 /srv /mnt 10.0.2.4 /mnt /mnt4
El resultado debería ser el siguiente:
EJECUTANDO KERNEL_LOG EN 10.0.2.33
RESULTADO UNREACHABLE SALIDA EN /tmp/kerlog-33.txt
EJECUTANDO KERNEL_LOG EN 10.0.2.4
RESULTADO ERROR=2 SALIDA EN /tmp/kerlog-4.txt
EJECUTANDO KERNEL_LOG EN 10.0.2.4
RESULTADO OK SALIDA EN /tmp/kerlog-4.txt
EJECUTANDO KERNEL_LOG EN 10.0.2.15
RESULTADO OK SALIDA EN /tmp/kerlog-15.txt
EJECUTANDO CREA_USUARIOS EN 10.0.2.4
RESULTADO OK SALIDA EN /tmp/usu_contra-4
EJECUTANDO CREA_USUARIOS EN 10.0.2.15
RESULTADO OK SALIDA EN /tmp/usu_contra-15
EJECUTANDO CREA_ALMACENAMIENTO EN 10.0.2.15
RESULTADO OK SALIDA EN /dev/null
EJECUTANDO NFS_SRV EN 10.0.2.4
RESULTADO OK SALIDA EN /dev/null
EJECUTANDO NFS_CLNT EN 10.0.2.15
RESULTADO OK SALIDA EN /dev/null
Entrega de la práctica
El plazo se extiende hasta el final del 16 de enero de 2023. Se realizará en la máquina triqui, usando el mandato:
entrega.asi proyecto.2023
Este mandato recogerá los siguientes ficheros:
autores: Fichero con los datos de los autores:
DNI APELLIDOS NOMBRE MATRÍCULA
memoria.txt: Memoria de la práctica. En ella, puede exponer los comentarios personales que considere oportuno.
crear_usuarios.sh.
configurar_almacenamiento.sh.
nfs_servidor.sh.
nfs_cliente.sh.
maestro.sh.