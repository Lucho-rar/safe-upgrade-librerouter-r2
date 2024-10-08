# Device tree - Linux Kernel
 Este Markdown fue adaptado de ["Device Tree: Hardware description for everybody!" - Thomas Petazzoni"](https://bootlin.com/pub/conferences/2020/lee/petazzoni-dt-hw-description-everybody/petazzoni-dt-hw-description-everybody.pdf).
## Mecanismos de Descubrimiento en Buses de Hardware

### Buses Descubribles 

Algunos buses de hardware proporcionan mecanismos de descubrimiento, permitiendo que los dispositivos sean detectados y configurados en tiempo de ejecución sin conocimiento previo de su conexión. Ejemplos:
- PCI
- USB

### Buses No Descubribles
Muchos buses de hardware no proporcionan mecanismos de descubrimiento, lo que significa que el sistema necesita estar preconfigurado con conocimiento sobre qué dispositivos están conectados y cómo están conectados. Ejemplos:
- I2C
- SPI
- Buses Mapeados en Memoria.

### Métodos para Describir el Hardware en Sistemas
1. Directamente en el código del SO/Bootloader: Descripciones de hardware embebidas directamente en el sistema operativo o código del bootloader, típicamente usando estructuras de datos compiladas escritas en C.
2. Usando tablas ACPI: Tablas proporcionadas por el firmware.
3. Device Tree.

### Device Tree
Device Tree es una estructura de datos utilizada para describir los componentes de hardware de un sistema. Proporciona un método independiente del sistema operativo para representar la plataforma de hardware, asegurando que el sistema operativo o el bootloader puedan interactuar correctamente con el hardware subyacente.

- Device Tree Source File (`.dts`): Legible por humanos y organizado en una estructura jerárquica que representa el diseño del hardware.
- Device Tree Blob (`.dtb`):  El `.dts` se compila en formato binario .dtb usando el Device Tree Compiler (`.dtc`).


### Sintaxis
La estructura de Device Tree se basa en un árbol de nodos, donde cada nodo representa un dispositivo o un bloque IP. Los nodos se definen con varias propiedades que describen las características del hardware.
- Nodos: Representan típicamente un dispositivo o un bloque IP. Cada nodo se identifica por un **nombre de nodo** y puede incluir una **dirección de unidad** para distinguir entre instancias del mismo tipo de dispositivo.
- Propiedades: Definen las características del dispositivo que representa el nodo. Cada propiedad consiste en un **nombre de propiedad** y un **valor de propiedad**. Las propiedades pueden almacenar diferentes tipos de valores, como cadenas, arreglos, etc.
- Etiquetas: Los nodos o propiedades pueden ser etiquetados para facilitar la referencia en la estructura de Device Tree. Se utilizan para referirse a un nodo o propiedad desde otra parte del Device Tree.

<p align="center">
  <img src="./img/labels.png"><br>
  <em>Fig. Syntax</em>
</p>


### Ubicación de las Fuentes de Device Tree

Aunque las fuentes de Device Tree están diseñadas para ser independientes del sistema operativo, no existe un repositorio central y neutral al sistema operativo para alojar y compartir estos archivos entre diferentes proyectos. Esto ha sido un tema de discusión, pero no se ha implementado una solución universal.

- Ubicación Canónica: En la práctica, el árbol de fuentes del núcleo de Linux a menudo se considera la ubicación principal para los archivos de fuente de Device Tree (`.dtS`). Dentro del núcleo de Linux, estos archivos generalmente se encuentran en el directorio `arch/<ARCH>/boot/dts`. 

- Escala Actual: A partir de la versión 5.10 del núcleo de Linux, hay aproximadamente 4700 archivos de fuente de Device Tree en el repositorio de Linux.

- Duplicación en Proyectos: Estos archivos de fuente de Device Tree a menudo se duplican o sincronizan en varios proyectos, incluidos U-Boot/Barebox, para asegurar compatibilidad y consistencia.

### Herencia en Device Tree

Los archivos de Device Tree (DT) están diseñados para ser modulares y no monolíticos, permitiendo que se dividan en múltiples archivos que pueden incluirse entre sí. Esta modularidad mejora la mantenibilidad y reutilización a través de diferentes plataformas de hardware.

Tipos de Archivos:
- `.tdsi`: Estos son archivos incluidos que generalmente contienen definiciones a nivel de SoC (System on Chip) u otras configuraciones comunes que pueden compartirse entre varias placas. Estos archivos se reutilizan a menudo en placas similares para evitar la duplicación de configuraciones comunes.
- `.dts`: Estos son los archivos finales de Device Tree que representan la configuración específica de una placa. Incluyen los archivos `.dtsi` necesarios y proporcionan detalles a nivel de placa.

Compilación:
- Solo los archivos .dts se aceptan como entrada por el compilador de Device Tree (`dtc`). El compilador procesa estos archivos para generar el Blob binario de Device Tree (`.dtb`).

Mecanismo de Inclusión:
- La inclusión de archivos `.dtsi` en archivos `.dts` funciona sobreponiendo la estructura del árbol del archivo incluido sobre el árbol del archivo que lo incluye.
- Esto se realiza utilizando la directiva `#includ`e del preprocesador de C, permitiendo descripciones de hardware jerárquicas y reutilizables.

Uso del Preprocesador de C:
- El preprocesador de C también se emplea para usar directivas `#define`, permitiendo el reemplazo de valores codificados con definiciones legibles por humanos. Esto mejora aún más la legibilidad y mantenibilidad.

<p align="center">
  <img src="./img/example_Inheritance.png"><br>
  <em>Fig. Example</em>
</p>

### Overlays de Device Tree

Las Superposiciones de Device Tree proporcionan una forma dinámica de modificar o extender el Device Tree base para acomodar componentes de hardware adicionales o configuraciones.

Una Superposición de Device Tree es un pequeño fragmento de un Device Tree que funciona como un parche para el DT principal. Se utiliza para describir dispositivos adicionales o modificar los existentes sin alterar el DT original.

U-Boot soporta la aplicación de superposiciones de DT. No hay soporte en Linux para aplicar superposiciones de DT, sin embargo.

Example: Examples: https://github.com/raspberrypi/linux/tree/rpi5.4.y/arch/arm/boot/dts/overlays/


### Estilos de Binding en Device Tree

***Old style***

```bash
I2C for Atmel platforms

Required properties :
- compatible : Must be one of:
        "atmel,at91rm9200-i2c",
        "atmel,at91sam9261-i2c",
        "atmel,at91sam9260-i2c",
        "atmel,at91sam9g20-i2c",
        "atmel,at91sam9g10-i2c",
        "atmel,at91sam9x5-i2c",
        "atmel,sama5d4-i2c",
        "atmel,sama5d2-i2c",
        "microchip,sam9x60-i2c".
- reg: physical base address of the controller and length of memory mapped
region.
- interrupts: interrupt number to the cpu.
- #address-cells = <1>;
- #size-cells = <0>;
- clocks: phandles to input clocks.
Optional properties:
- clock-frequency: Desired I2C bus frequency in Hz, otherwise defaults
to 100000
- dmas: A list of two dma specifiers, one for each entry in
dma-names.
- dma-names: should contain "tx" and "rx".
- scl-gpios: specify the gpio related to SCL pin
- sda-gpios: specify the gpio related to SDA pin
[...]
```

```bash
Examples :
i2c0: i2c@fff84000 {
   compatible = "atmel,at91sam9g20-i2c";
   reg = <0xfff84000 0x100>;
   interrupts = <12 4 6>;
   #address-cells = <1>;
   #size-cells = <0>;
   clocks = <&twi0_clk>;
   clock-frequency = <400000>;

 24c512@50 {
    compatible = "atmel,24c512";
    reg = <0x50>;
    pagesize = <128>;
 }
}
```

***YAML style***

```yaml
# SPDX-License-Identifier: (GPL-2.0 OR BSD-2-Clause)
# Copyright 2019 BayLibre, SAS
%YAML 1.2
---
$id: "http://devicetree.org/schemas/i2c/amlogic,meson6-i2c.yaml#"
$schema: "http://devicetree.org/meta-schemas/core.yaml#"
title: Amlogic Meson I2C Controller
maintainers:
- Neil Armstrong <narmstrong@baylibre.com>
- Beniamino Galvani <b.galvani@gmail.com>
allOf:
- $ref: /schemas/i2c/i2c-controller.yaml#
properties:
compatible:
enum:
- amlogic,meson6-i2c # Meson6, Meson8 and compatible SoCs
- amlogic,meson-gxbb-i2c # GXBB and compatible SoCs
reg:
maxItems: 1
interrupts:
maxItems: 1

clocks:
minItems: 1
required:
- compatible
- reg
- interrupts
- clocks
unevaluatedProperties: false
examples:
- |
  i2c@c8100500 {
  compatible = "amlogic,meson6-i2c";
  reg = <0xc8100500 0x20>;
  interrupts = <92>;
  clocks = <&clk81>;
  #address-cells = <1>;
  #size-cells = <0>;
    eeprom@52 {
    compatible = "atmel,24c32";
    reg = <0x52>;
    };
  };
```

### Principios de Diseño del Device Tree


1. *Describir el Hardware, No la Configuración*: El papel principal del DT es describir el hardware tal como es, en lugar de cómo se configura o utiliza el hardware. Esto asegura que el DT siga siendo una representación consistente del hardware, independiente de configuraciones o casos de uso específicos.

2. *Independiente del Sistema Operativo*: Un DT bien diseñado es independiente del sistema operativo, lo que significa que el mismo DT debería funcionar en diferentes sistemas operativos como U-boot, FreeBSD, Linux. No debería ser necesario modificar el DT al actualizar o cambiar de sistema operativo, asegurando compatibilidad y mantenibilidad a largo plazo.

3. *Describir Integración, No Internos*: El DT se enfoca en describir la integración de los componentes de hardware, en lugar del funcionamiento interno de cada componente. Los detalles sobre cómo funciona internamente un dispositivo o bloque IP son gestionados por los controladores de dispositivos en el sistema operativo. El DT especifica cómo los dispositivos están conectados e interactúan con el resto del sistema, incluyendo aspectos como líneas IRQ, canales DMA, relojes, líneas de reinicio.

### Propiedad `compatible`
Esta es una lista de cadenas que describen la compatibilidad de un dispositivo con controladores o bindings específicos. Las cadenas están ordenadas de la más específica a la menos específica, ayudando al sistema operativo o firmware a identificar el controlador correcto para el dispositivo.

La propiedad define el binding específico al que cumple el nodo, describiendo esencialmente el modelo de programación del dispositivo. En la práctica, se utiliza por el SO para encontrar y cargar el controlador apropiado para el dispositivo.

Example:
```
compatible = "arm,armv8-timer";
compatible = "actions,s900-uart", "actions,owl-uart";
compatible = "regulator-fixed";
compatible = "gpio-keys";
```

### Propiedades Comunes

- `reg`:  Dispositivos mapeados en memoria (dirección base y tamaño de los registros). Dispositivos I2C. Dispositivos SPI.
- `interrupts, interrupt-parent, interrupts-extended`: líneas de interrupción utilizadas por el dispositivo y a qué controlador de interrupciones están conectadas.
- `clocks`: qué reloj utiliza el dispositivo y de qué controlador de reloj proviene.
- `dmas`: qué controlador DMA y canales utiliza el dispositivo.
-`status`: `okay` significa que el dispositivo está presente y debe estar habilitado; de lo contrario, el dispositivo queda sin usar.
-`pinctrl-*`: indica la configuración de multiplexión de pines solicitada por el dispositivo.

### Concepto de `Cells`

- Enteros de 32 bits: en DT, los valores enteros se representan como enteros de 32 bits, que se denominan celdas.
- Valores de 64 bits: Para codificar un valor de 64 bits, se utilizan dos celdas.

Propiedades Importantes de las Celdas:
- `#address-cells and #size-cells`: Estas propiedades definen cuántas celdas se utilizan en los sub-nodos para codificar la dirección y el tamaño en la propiedad `reg`.

```yaml
soc {
  compatible = "simple-bus";
  #address-cells = <1>;
  #size-cells = <1>;
  i2c@f1001000 {
    reg = <0xf1001000 0x1000>;
    #address-cells = <1>;
    #size-cells = <0>;
    eeprom@52 {
      reg = <0x52>;
    };
  };
};
```

- `#interrupt-cells`:
 Especifica el número de celdas utilizadas para codificar los especificadores de interrupción para un controlador de interrupciones dado.

```yaml
soc {
  intc: interrupt-controller@f1002000 {
    compatible = "foo,bar-intc";
    reg = <0xf1002000 0x1000>;
    interrupt-controller;
    #interrupt-cells = <2>;
  };
  i2c@f1001000 {
    interrupt-parent = <&intc>;
    /* Must have two cells */
    interrupts = <12 24>;
  };
};
```

- Propiedades Adicionales de Celdas `#clock-cells` `#gpio-cells` `#phy-cells` `#pwm-cells` `#dma-cells`

```yaml
soc {
  clkc: clock@f1003000 {
    compatible = "foo,bar-clock";
    reg = <0xf1003000 0x1000>;
    #clock-cells = <3>;
  };
  i2c@f1001000 {
    /* Must have three cells */
    clocks = <&clkc 12 24 32>;
  };
};

```

### Propiedades `-names`

Algunas propiedades están asociadas a una propiedad `<prop>-names` correspondiente. Proporciona nombres legibles por humanos para las entradas de las propiedades `<prop> ` correspondientes.


```yaml
interrupts = <0 59 0>, <0 70 0>;
interrupt-names = "macirq", "macpmt";
clocks = <&car 39>, <&car 45>, <&car 86>, <&car 87>;
clock-names = "gnssm_rgmii", "gnssm_gmac", "rgmii", "gmac";
```

Estos nombres pueden ser utilizados típicamente por el controlador.

*platform_get_irq_byname(pdev, "macirq");*
