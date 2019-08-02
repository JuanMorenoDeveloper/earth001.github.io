---
title: Tipos de inyección de dependencias con Spring
date: 2017-12-06T04:33:31+00:00
author: Juan Moreno
layout: post
comments: true
permalink: /inyeccion-de-dependencias-spring/
image: /wp-content/uploads/2017/12/spring-logo.png
categories:
  - java
  - spring
---
# Introducción

La inyección de dependencias es un patrón de desarrollo de software donde los objetos no son responsables de inicializar sus dependencias, sino que estas son provistas a través de otro objeto. En el caso de Spring ese objeto es el contenedor IoC el cual es provisto por los módulos spring-core y spring-beans.
  
En este articulo, mostraremos los diferentes tipos de inyección de beans que disponemos con Spring.

## Dependencias

Para usar la funcionalidades básicas del contenedor y la inyección de dependencias necesitamos agregar las siguientes dependencias a nuestro proyecto maven:

```xml
<dependency>
    <groupId>org.springframework</groupId>
    <artifactId>spring-context</artifactId>
    <version>5.0.1.RELEASE</version>
</dependency>
```

Las versiones más recientes las encontramos en [Maven Central](https://mvnrepository.com/artifact/org.springframework)
  
Si adicionalmente queremos usar las anotaciones del estándar JSR-330 debemos agregar esta también:

```xml
<dependency>
    <groupId>javax.inject</groupId>
    <artifactId>javax.inject</artifactId>
    <version>1</version>
</dependency>
```

# Tipos de inyección de dependencias

Las variantes de DI soportadas por el contenedor IoC de Spring son constructor, setter y field.

## 1. Constructor

En este caso el contenedor se encarga de invocar el constructor de la clase pasando los argumentos como dependencias. Es la recomendada para la mayoría de los casos, puedes leer mas detalles en este [post](http://olivergierke.de/2013/11/why-field-injection-is-evil/) de Oliver Gierke (Spring Data) o en la [documentacion](https://docs.spring.io/spring/docs/current/spring-framework-reference/core.html#beans-factory-collaborators) de Spring.

## 2. Setter

Aquí el contenedor asigna las dependencias usando los métodos setter de los atributos. Recomendada para dependencias opcionales.

## 3. Field

En este caso no se requiere un método para la asignación de la dependencia sino que esta se asigna a través del API de reflexión. Se usa para casos muy básicos y generalmente no recomendada.

# Configuración

Para configurar la inyección de dependencias tenemos dos opciones, usar configuración XML y JavaConfig con anotaciones de Spring.

## 1. XML

Para hacer esto partiremos del archivo application-context.xml que tenemos en la carpeta resources de nuestra aplicación. Vamos a definir dos beans, un _dataSource_ con propiedades de conexión a una base de datos, las cuales inicializaremos a través del Contenedor IoC y un _dataBaseService_ que tomara el _dataSource_.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd">
    <bean id="dataSource" class="ve.com.proitcsolution.service.DataSource">
        <property name="driverClassName" value="com.mysql.jdbc.Driver" />
	<property name="url" value="jdbc:mysql://127.0.0.1/" />
	<property name="username" value="username" />
	<property name="password" value="password" />
    </bean>
    <bean id="dataBaseService" class="ve.com.proitcsolution.service.DatabaseServiceWithoutAnnotations">
        <constructor-arg ref="dataSource" />
    </bean>
</beans>
```

La inyección de los atributos del _dataSource_ son inicializadas a través de setter-inyección con la etiqueta _property_, la inyección del _dataSource_ a través del constructor en la clase _dataBaseService_ se hace con la etiqueta _constructor-arg_.

La inyección de tipo field no es compatible con la configuración XML y requiere el uso de anotaciones.

&nbsp;

## 2. JavaConfig

La configuración usando JavaConfig es mucho menos verbosa y solo requiere el uso de anotaciones especificas del framework.

  * _@Configuration_: Para marcar que esta clase va inicializar beans
  * _@ComponentScan_: Para buscar beans con anotaciones Spring
  * _@Bean_: En métodos que inicializan bean

En ejemplo lo podemos ver en la siguiente clase:

```java
@Configuration
@ComponentScan(basePackages = {"ve.com.proitcsolution.service"})
public class JavaConfig {

  @Bean
  public DataSource dataSource() {
    DataSource dataSource = new DataSource();
    dataSource.setDriverClassName("com.mysql.jdbc.Driver");
    dataSource.setUrl("jdbc:mysql://127.0.0.1/");
    dataSource.setUsername("production username");
    dataSource.setPassword("production password");
    return dataSource;
  }

  @Bean
  public AuditService auditService() {
    AuditService auditService = new AuditService("INFO");
    return auditService;
  }
}
```

# Uso

Una vez configurados nuestros beans podemos usarlos a través de anotaciones de Spring y anotaciones del JSR-330

## 1 Anotaciones de Spring

El framework provee anotaciones especificas para declaración de beans como _@Component_, _@Service_, _@Repository_ y para inyección _@Autowire_, las primeras se usan sobre los tipos y la última en los puntos de inyección.
  
En el siguiente ejemplo las clase _DatabaseService_ inicializa la dependencia _dataSource_ a través del constructor y la dependencia _auditService_ a través del setter:

```java
@Service
public class DatabaseService {

  private DataSource dataSource;
  private AuditService auditService;

  @Autowired
  public DatabaseService(DataSource dataSource) {
    this.dataSource = dataSource;
  }

  @Autowired
  public void setAuditService(AuditService auditService) {
    this.auditService = auditService;
  }
}
```

## 2 Anotaciones estándar JSR 330

A través del JSR 330 &#8220;Dependency Injection for Java&#8221; se estandarizaron las anotaciones para DI, y entre las disponibles tenemos _@Inject_ para inyección de componentes y _@Named_ para declaración de beans.
  
Si bien _@Inject_ y _@Autowire_ son equivalentes pero _@Autowire_ provee funcionales adicionales a las del estandar. Y lo mismo pasa para _@Named_ y _@Component_.
  
En el siguiente test se ve un ejemplo del uso de las anotación _@Inject_, en este caso el tipo de inyección que se usa es field.

```java
@SpringJUnitConfig(JavaConfig.class)
public class DependencyInjectionJavaConfigTest {

  @Inject
  DatabaseService databaseService;
  @Inject
  DataSource dataSource;
  @Inject
  AuditService auditService;
  //Tests...
}
```

# Conclusión

En este artículo vimos un ejemplo de como usar las tres tipos de inyección de dependencias con Spring, sus características y las opciones de configuración disponibles.
  
El código completo esta disponible en [Github](https://github.com/earth001/spring-di-examples).

&nbsp;