---
title: Testing Unitario. ¡Más allá de comprobar funcionamiento!
date: 2019-07-30T01:53:29+00:00
author: Juan Moreno
layout: post
comments: true
exclude: true
permalink: /testing-unitario-mas-alla-de-comprobar-funcionamiento/
image: /wp-content/uploads/2019/07/avoid-legacy.png

categories:
  - spanish
  - testing
---

Cuando comienzas en el mundo de la programación con cosas sencillas y empiezas a hacer todo desde cero es fácil seguir el ciclo común: editar, compilar, ejecutar y probar, pero, ¿qué sucede cuando se vienen más capas y más interfaces complejas?, ¿cuándo los datos vienen de más allá del teclado? ¿o cuando comienzas a tener salidas más complejas que un carácter, como pixeles, posiciones, coordenadas? Es ahí donde la simplicidad que tenían nuestras primeras aplicaciones se empieza a perder, y el cuarto paso del ciclo común "probar" se vuelve lento y nos hace menos eficientes.

Aunque tengas a la mano y manejes con fluidez algunos patrones de diseño, arquitecturas, técnicas de POO, **necesitas hacer Test Unitario si quieres tener la certeza de que tu sistema no se va a romper con facilidad ante los cambios, más que escribirlos para validar lo que hiciste, blinda tu sistema para las futuras modificaciones**. Pero, como sé que todo debe tener una razón de ser para que podamos creer que de verdad funciona, te dejo estas cuatro simples preguntas:

## 1. ¿Quieres Feedback rápido? Haz Test Unitario.

Si necesitas desarrollar una nueva funcionalidad enfócate solo en el nuevo requerimiento, no es necesario que compiles todo el sistema para probar que lo que hiciste funciona, el test unitario te permite aislar de dependencias externas por lo que el feedback viene directo del método o la clase desarrollada lo que no debe tomar más de unos pocos segundos por no decir milisegundos.

## 2. ¿Quieres ser más productivo? Haz Test Unitario.

Qué mejor manera de aumentar la productividad que una alerta que te avise cuando ingreses una nueva funcionalidad que rompe algo en tu aplicación, y todo esto sin tener que esperar a probar todo o que el cliente te avise que algo dejó de funcionar o está funcionando mal, no escribimos test unitarios solo para validar que un sistema funciona sino para que siga funcionando.

## 3. ¿Quieres diseñar mejor? Haz Test Unitario.

Los test evidencian las dependencias del sistema y de sus clases, a mayor cantidad, mayor responsabilidad. Los test unitarios te pueden servir de semáforo para mantener el control y mantener acotadas las responsabilidades de cada clase. Una clase que es testeable está potencialmente bien diseñada.

## 4. ¿Quieres documentar la intención de tu código? Haz Test Unitario.

No es lo mismo leer la intención de un código que verlo funcionando directamente y que mejor manera de documentar código que haciendo código. Escribir test unitarios es una técnica infalible que no permite desfasajes como suele suceder cuando la documentación que está separada, o cuando viene de un comentario que depende del estado de ánimo o del nivel de premura que tengamos, con los test unitarios se evidencian las entradas y salidas de una funcionalidad lo que nos sirve de guía para saber si preservamos algún funcionamiento o si se ve afectado por algún cambio.

En fin, como en toda técnica de desarrollo no existen balas de plata, bien podemos caer en el testeo de los caminos felices o en la obsesión por el porcentaje de cobertura, aunque ya esto vendría siendo tema para un próximo capítulo, lo que sí nos puede dar es una buena base para comenzar a agregar calidad al código que desarrollemos.

## Sé de los buenos no escribas código Legacy (código sin Tests).