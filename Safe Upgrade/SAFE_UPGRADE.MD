# Safe Upgrade - LibreMesh Package

# Resumen

En este documento se lleva a cabo un desarrollo teórico sobre “Safe Upgrade”. Como fuente de información se sigue la documentación de LibreMesh en "["Safe-upgrade -  LiMe documentation"](https://libremesh.org/packages/safe-upgrade.html).".

# Safe Upgrade

El safe-upgrade brinda la posibilidad de poder actualizar el firmware de un dispositivo de manera _segura_, utilizando dos particiones y un paso de confirmación que se aclara más adelante en el documento. En la documentación de LibreMesh se aclara que esta característica es solamente soportada en los dispositivos LibreRouter.

# Uso práctico

La documentación específica los pasos a seguir para lanzar el upgrade.

1. Se lanza `safe-upgrade upgrade xxx-sysupgrade.bin`. El primer comando específica al dispositivo que se corre una actualización del firmware pero no en la partición que se tiene en uso, sino en otra. Esto da la “seguridad” de no romper la configuración del firmware que está corriendo en la partición en uso.
2. Reiniciar el dispositivo con `reboot`.
3. Luego se debe validar que el firmware nuevo funciona correctamente, de lo contrario se puede correr `reboot` nuevamente para cancelarlo.
4. Por último se realiza la confirmación del upgrade con `safe-upgrade confirm`. Esto se realiza antes de un período de tiempo que está seteado por default en 10 minutos, ya que si no se confirma en ese período se realiza un reboot automático y el dispositivo arranca en la última partición donde fue confirmado.

# Flags y especificaciones

- `safe-upgrade --help`: Ofrece una lista de comandos de ayuda.
- `safe-upgrade show`: Muestra el estado actual de las particiones.
- `-n`: Funciona de la misma manera que --do-not-preserve-config y lo que especifica es no guardar la configuración actual en la nueva partición. 
- También existen flags para deshabilitar el reboot automático o setear el tiempo del mismo especificado en el punto 4 del uso práctico.  `--reboot-safety-timeout=600` `--disable-reboot-safety`.
- `safe-upgrade bootstrap`: Instala el mecanismo de safe-upgrade en el bootloader. 

# Cómo trabaja el safe-upgrade

Instalado el safe-upgrade en el bootloader:

```c
if testing_partition != None:
    boot_partition = testing_partition
    testing_partition = None # a testing partition will boot just once
else:
    boot_partition = stable_partition

boot(boot_partition)
```

La partición estable puede tener los valores 1 o 2, y en el caso de la testing puede acceder a None, o así mismo 1 y 2. En la documentación especifica el ejemplo donde la partición estable es 1 y la de testing es None. Cuando se lanza el safe-upgrade la partición de testing se cambia de None a otra partición no estable (2).  Cuando el dispositivo, el script define otra vez el testing en None pero inicializará la partición 2, luego si es confirmada, la partición estable pasará de 1 a 2. 

# Referencias

https://libremesh.org/packages/
https://github.com/libremesh/lime-packages/tree/master/packages/safe-upgrade