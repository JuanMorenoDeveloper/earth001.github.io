---
title: WS-Security con signing usando Spring Boot y Apache CXF
date: 2017-03-10T02:07:52+00:00
author: Juan Moreno
layout: post
permalink: /ws-security-con-signing-usando-spring-boot-y-apache-cxf/
image: /wp-content/uploads/2017/03/padlock-xxl.png
categories:
  - cxf
  - java
  - security
  - spring
tags:
  - spring
---
# Descripción General

Dentro de [WS-Security](http://cxf.apache.org/docs/ws-security.html) existen varias alternativas para asegurar los servicios Web, bien sea signing, encriptación, usuario/password y marca de tiempo. Todas estas alternativas se pueden combinar o usar independientemente para asegurar nuestro servicio, dependiendo del caso de uso.

A continuación les dejo un ejemplo del uso de WS-Security con signing usando Spring Boot y Apache CXF; la integración de Apache CXF y Spring Boot la tomé del Blog [codecentric](https://blog.codecentric.de/en/2016/02/spring-boot-apache-cxf/) (excelente material!). Las herramientas que necesitaremos serán las siguientes:

  * Maven 3
  * Java 8
  * El IDE de su preferencia (Yo uso STS)

Bien, manos a la obra!

# Generación de Certificados

Necesitaremos en primer lugar un certificado de prueba, esto es, porque la información que intercambiaremos irá firmada con estos certificados.

El proceso de firmado funciona con algoritmos asimétricos que pueden encontrar con mas detalle [aquí](https://en.wikipedia.org/wiki/Digital_signature). La idea básicamente es: &#8220;Lo que firmas con tu clave pública lo puedes verificar con tu clave privada&#8221;. Para generarlos existen diferentes alternativas como openssl y keytool, éste último viene dentro de los binarios de la JVM por lo que se puede usar teniendo Java instalado.

El comando para generar certificado de prueba es:

`keytool -genkey -alias ws-security-spring-boot-cxf -keyalg RSA -keystore keystore.jks -keysize 2048`

donde, _-alias_ es el identificador del certificado, _-keyalg_ es el tipo de algoritmo, _-keystore_ es el archivo almacén del certificado y _-keysize_ es el tamaño en bit de las llaves.

Una vez configurado el certificado ya tenemos lo necesario para configurar nuestro servidor y nuestro cliente.

# Estructura del Servidor

En la figura 1  se observa el directorio del proyecto del servidor

![Figura 1. Proyecto del servidor](/wp-content/uploads/2017/03/server-wss-spring.png)

Figura 1. Proyecto del servidor

A continuación muestro el archivo pom.xml con las dependencias usadas en el servidor:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>

  <groupId>com.proitc</groupId>
  <artifactId>ws-security-spring-boot-cxf-server</artifactId>
  <version>0.0.1</version>
  <packaging>jar</packaging>

  <name>ws-security-spring-boot-cxf-server</name>
  <description>Demo project for Spring Boot</description>

  <parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-parent</artifactId>
    <version>1.4.2.RELEASE</version>
    <relativePath/>
  </parent>

  <properties>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    <project.reporting.outputEncoding>UTF-8</project.reporting.outputEncoding>
    <java.version>1.8</java.version>
    <cxf.version>3.1.8</cxf.version>
    <wssj4.version>1.6.19</wssj4.version>
    <apacheCommons.version>3.5</apacheCommons.version>
    <jaxwsMavenPlugin.version>2.4.1</jaxwsMavenPlugin.version>
  </properties>

  <dependencies>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-devtools</artifactId>
    </dependency>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <!-- Apache CXF -->
    <dependency>
      <groupId>org.apache.cxf</groupId>
      <artifactId>cxf-rt-frontend-jaxws</artifactId>
      <version>${cxf.version}</version>
    </dependency>
    <dependency>
      <groupId>org.apache.cxf</groupId>
      <artifactId>cxf-rt-transports-http</artifactId>
      <version>${cxf.version}</version>
    </dependency>
    <dependency>
      <groupId>org.apache.cxf</groupId>
      <artifactId>cxf-rt-ws-security</artifactId>
      <version>${cxf.version}</version>
    </dependency>
    <dependency>
      <groupId>org.apache.cxf</groupId>
      <artifactId>cxf-rt-ws-policy</artifactId>
      <version>${cxf.version}</version>
    </dependency>
    <!-- Apache commons -->
    <dependency>
      <groupId>org.apache.commons</groupId>
      <artifactId>commons-lang3</artifactId>
      <version>${apacheCommons.version}</version>
    </dependency>
    <!-- Test -->
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-test</artifactId>
      <scope>test</scope>
    </dependency>
  </dependencies>

  <build>
    <plugins>
      <plugin>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-maven-plugin</artifactId>
      </plugin>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-surefire-plugin</artifactId>
        <configuration>
          <excludes>
            <exclude>**/*IntegrationTest.java</exclude>
          </excludes>
        </configuration>
      </plugin>
    </plugins>
  </build>
  <profiles>
    <profile>
      <id>generate-wsdl</id>
      <activation>
        <property>
          <name>generate-wsdl</name>
        </property>
      </activation>
      <build>
        <plugins>
          <plugin>
            <groupId>org.apache.cxf</groupId>
            <artifactId>cxf-java2ws-plugin</artifactId>
            <version>${cxf.version}</version>
            <dependencies>
              <dependency>
                <groupId>org.apache.cxf</groupId>
                <artifactId>cxf-rt-frontend-jaxws</artifactId>
                <version>${cxf.version}</version>
              </dependency>
              <dependency>
                <groupId>org.apache.cxf</groupId>
                <artifactId>cxf-rt-frontend-simple</artifactId>
                <version>${cxf.version}</version>
              </dependency>
            </dependencies>
            <executions>
              <execution>
                <id>process-classes-endpoint</id>
                <phase>process-classes</phase>
                <configuration>
                  <className>com.proitc.wss.endpoint.DemoServiceEndpoint</className>
                  <genWsdl>true</genWsdl>
                  <verbose>true</verbose>
                </configuration>
                <goals>
                  <goal>java2ws</goal>
                </goals>
              </execution>
            </executions>
          </plugin>
        </plugins>
      </build>
    </profile>
  </profiles>
</project>
```

# Definición del servicio

El servicio que vamos a exponer es bastante sencillo, y contiene un solo método al que llamaremos `status`. Esta definido en la interfaz `DemoService` del paquete `com.proitc.wss.sei`.

```java
package com.proitc.wss.sei;

import javax.jws.WebService;

@WebService(targetNamespace = "http://endpoint.wss.proitc.com/")
public interface DemoService {
  public String status();
}
```

La implementación de la interfaz se encuentra en la clase `DemoServiceEndpoint`, donde para efectos de este ejemplo simplemente devolveremos &#8220;OK&#8221;. En caso que quisiéramos agregar más métodos simplemente los agregaremos a la interfaz.

# Configuración del servidor

La configuración del servidor se encuentra en la clase `WebServiceConfiguration`

```java
@Configuration
@PropertySource("application-${spring.profiles.active}.properties")
public class WebServiceConfiguration {
  private static final Logger log = LoggerFactory.getLogger(WebServiceConfiguration.class.getName());
  @Value("${service.contextPath}")
  private String contextPath;
  @Value("${service.endpointUrl}")
  private String endpointUrl;
  @Value("${service.wsdlLocation}")
  private String wsdlLocation;
  /* Datos keystore */
  @Value("${keystore.alias}")
  private String keystoreAlias;
  @Value("${keystore.password}")
  private String keystorePassword;
  @Value("${keystore.file}")
  private String keystoreFile;
  @Value("${keystore.type}")
  private String keystoreType;

  /**
   * Contexto del servicio
   */
  @Bean
  public ServletRegistrationBean dispatcherServlet() {
    return new ServletRegistrationBean(new CXFServlet(), contextPath);
  }

  /**
   * Bus de integración CXF/Spring
   */
  @Bean(name = DEFAULT_BUS_ID)
  public SpringBus springBus() {
    SpringBus springBus = new SpringBus();
    springBus.setFeatures(Arrays.asList(new LoggingFeature()));
    return springBus;
  }

  /**
   * Implementación del servicio
   */
  public DemoService demoServiceEndpoint() {
    return new DemoServiceEndpoint();
  }

  /**
   * Ubicación del wsdl y el endpoint
   */
  @Bean
  public Endpoint endpoint() {
    EndpointImpl endpoint = new EndpointImpl(springBus(), demoServiceEndpoint());
    endpoint.publish(endpointUrl);
    log.info("Publicando servicio en " + endpointUrl);
    endpoint.setWsdlLocation(wsdlLocation);
    endpoint.getOutInterceptors().add(wss4jOut());
    //endpoint.getInInterceptors().add(wss4jIn());
    return endpoint;
  }

  public WSS4JOutInterceptor wss4jOut() {
    Map<String, Object> properties = new HashMap<>();
    properties.put(ConfigurationConstants.ACTION,
        ConfigurationConstants.SIGNATURE + " " + ConfigurationConstants.TIMESTAMP);
    properties.put("signingProperties", wss4jOutProperties());
    properties.put(ConfigurationConstants.SIG_PROP_REF_ID, "signingProperties");
    properties.put(ConfigurationConstants.SIG_KEY_ID, "DirectReference");
    properties.put(ConfigurationConstants.USER, keystoreAlias);
    properties.put(ConfigurationConstants.SIGNATURE_PARTS,
        "{Element}{http://schemas.xmlsoap.org/soap/envelope/}Body");
    properties.put(ConfigurationConstants.PW_CALLBACK_REF, clientKeystorePasswordCallback());
    properties.put(ConfigurationConstants.SIG_ALGO, "http://www.w3.org/2000/09/xmldsig#rsa-sha1");
    WSS4JOutInterceptor interceptor = new WSS4JOutInterceptor(properties);
    return interceptor;
  }

  public Properties wss4jOutProperties() {
    Properties properties = new Properties();
    properties.put("org.apache.wss4j.crypto.merlin.provider", "org.apache.wss4j.common.crypto.Merlin");
    properties.put("org.apache.wss4j.crypto.merlin.keystore.type", keystoreType);
    properties.put("org.apache.wss4j.crypto.merlin.keystore.password", keystorePassword);
    properties.put("org.apache.wss4j.crypto.merlin.keystore.alias", keystoreAlias);
    properties.put("org.apache.wss4j.crypto.merlin.keystore.file", keystoreFile);
    return properties;
  }

  public CallbackHandler clientKeystorePasswordCallback() {
    Map<String, String> passwords = new HashMap<>();
    passwords.put(keystoreAlias, keystorePassword);
    return new ClientKeystorePasswordCallback(passwords);
  }

}
```

Esta clase toma las propiedades `@Value` de los archivos de application.yml y application-dev.properties, en ellos están los datos del contexto, url del servicio y parámetros del keystore.

El método encargado de configurar la seguridad es `public WSS4JOutInterceptor wss4jOut()` este toma las propiedades del certificado y configura el interceptor de los mensajes salientes. Los [interceptores](http://cxf.apache.org/docs/interceptors.html) en Apache CXF se encargan de hacer transformaciones y validar los mensajes.

En la línea 62 y 63 se ve como configura la acción de firma y marca de tiempo de los mensajes.

# Estructura del cliente

En la figura 2 se observa la estructura del proyecto del cliente:

![Figura 2. Estructura del proyecto del cliente](/wp-content/uploads/2017/03/client-wss-spring.png)

Figura 2. Estructura del proyecto del cliente

Las dependencias del cliente son la siguientes:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>

  <groupId>com.proitc</groupId>
  <artifactId>ws-security-spring-boot-cxf-client</artifactId>
  <version>0.0.1</version>
  <packaging>jar</packaging>

  <name>ws-security-spring-boot-cxf-client</name>
  <description>Demo project for Spring Boot</description>

  <parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-parent</artifactId>
    <version>1.4.2.RELEASE</version>
    <relativePath />
  </parent>

  <properties>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    <project.reporting.outputEncoding>UTF-8</project.reporting.outputEncoding>
    <java.version>1.8</java.version>
    <cxf.version>3.1.8</cxf.version>
    <wssj4.version>1.6.19</wssj4.version>
    <apacheCommons.version>3.5</apacheCommons.version>
    <jaxwsMavenPlugin.version>2.4.1</jaxwsMavenPlugin.version>
  </properties>

  <dependencies>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-devtools</artifactId>
    </dependency>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <!-- Apache CXF -->
    <dependency>
      <groupId>org.apache.cxf</groupId>
      <artifactId>cxf-rt-frontend-jaxws</artifactId>
      <version>${cxf.version}</version>
    </dependency>
    <dependency>
      <groupId>org.apache.cxf</groupId>
      <artifactId>cxf-rt-transports-http</artifactId>
      <version>${cxf.version}</version>
    </dependency>
    <dependency>
      <groupId>org.apache.cxf</groupId>
      <artifactId>cxf-rt-ws-security</artifactId>
      <version>${cxf.version}</version>
    </dependency>
    <dependency>
      <groupId>org.apache.cxf</groupId>
      <artifactId>cxf-rt-ws-policy</artifactId>
      <version>${cxf.version}</version>
    </dependency>
    <!-- Apache commons -->
    <dependency>
      <groupId>org.apache.commons</groupId>
      <artifactId>commons-lang3</artifactId>
      <version>${apacheCommons.version}</version>
    </dependency>
    <!-- Test -->
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-test</artifactId>
      <scope>test</scope>
    </dependency>
  </dependencies>

  <build>
    <plugins>
      <plugin>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-maven-plugin</artifactId>
      </plugin>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-surefire-plugin</artifactId>
        <configuration>
          <excludes>
            <exclude>**/*IntegrationTest.java</exclude>
          </excludes>
        </configuration>
      </plugin>
    </plugins>
  </build>
  <profiles>
    <profile>
      <id>generate-client</id>
      <activation>
        <property>
          <name>generate-client</name>
        </property>
      </activation>
      <build>
        <plugins>
          <plugin>
            <groupId>org.codehaus.mojo</groupId>
            <artifactId>jaxws-maven-plugin</artifactId>
            <version>${jaxwsMavenPlugin.version}</version>
            <configuration>
              <wsdlDirectory>
                ../client/src/main/resources/service-api-definition/
              </wsdlDirectory>
              <wsdlLocation>/service-api-definition/*</wsdlLocation>
              <keep>true</keep>
              <wsdlFiles>
                <wsdlFile>DemoServiceEndpoint.wsdl</wsdlFile>
              </wsdlFiles>
              <sourceDestDir>src/main/java</sourceDestDir>
              <vmArgs>
                <vmArg>-Djavax.xml.accessExternalSchema=all</vmArg>
              </vmArgs>
            </configuration>
            <executions>
              <execution>
                <goals>
                  <goal>wsimport</goal>
                </goals>
              </execution>
            </executions>
          </plugin>
          <plugin>
            <groupId>org.codehaus.mojo</groupId>
            <artifactId>build-helper-maven-plugin</artifactId>
            <executions>
              <execution>
                <id>add-source</id>
                <phase>generate-sources</phase>
                <goals>
                  <goal>add-source</goal>
                </goals>
                <configuration>
                  <sources>
                    <source>src/main/java</source>
                  </sources>
                </configuration>
              </execution>
            </executions>
          </plugin>
        </plugins>
      </build>
    </profile>
  </profiles>
</project>
```

# Generación del cliente SOAP

Para generar el cliente vamos a necesitar el wsdl de los servicios, para crearlo basta con ejecutar el perfil generate-wsdl del pom.xml del servidor.
  
`$ mvn clean install -Pgenerate-wsdl -Dgenerate-wsdl`
  
Luego de hacerlo tendremos en la carpeta target/generated/wsdl el wsdl de los endpoints que tengamos para procesar.

El wsdl lo copiamos en la carpeta src/main/resources/service-api-definition, y creamos las clases del cliente ejecutando el perfil generate-client del pom.xml del cliente.
  
`$ mvn clean install -Pgenerate-client -Dgenerate-client`

# Configuración del cliente

La clase de configuración del cliente es similar a la del servidor WebServiceConfiguration, pero en este caso vamos a configurar es un interceptor entrante.

```java
@Configuration
@PropertySource("classpath:application-${spring.profiles.active}.properties")
public class WebServiceConfiguration {
  private static final Logger log = LoggerFactory.getLogger(WebServiceConfiguration.class.getName());
  @Value("${service.url}")
  private String serviceUrl;
  /* Datos truststore */
  @Value("${truststore.alias}")
  private String truststoreAlias;
  @Value("${truststore.password}")
  private String truststorePassword;
  @Value("${truststore.file}")
  private String truststoreFile;
  @Value("${truststore.type}")
  private String truststoreType;

  /**
   * Servicio Cliente
   */
  @Bean(name = "recepcionWSClient")
  public DemoServiceEndpointPortType efacturaConsultasClient() {
    JaxWsProxyFactoryBean jaxWsProxyFactory = new JaxWsProxyFactoryBean();
    jaxWsProxyFactory.setServiceClass(DemoServiceEndpointPortType.class);
    jaxWsProxyFactory.setAddress(serviceUrl);
    log.info("Consumiendo servicio de " + serviceUrl);
    jaxWsProxyFactory.getInInterceptors().add(wss4jIn());
    return (DemoServiceEndpointPortType) jaxWsProxyFactory.create();
  }

  /* WSS4JInInterceptor para validar firma del servidor */
  public WSS4JInInterceptor wss4jIn() {
    Map<String, Object> properties = new HashMap<>();
    properties.put(ConfigurationConstants.ACTION,
        ConfigurationConstants.SIGNATURE + " " + ConfigurationConstants.TIMESTAMP);
    properties.put("signingProperties", wss4jInProperties());
    properties.put(ConfigurationConstants.SIG_PROP_REF_ID, "signingProperties");
    properties.put(ConfigurationConstants.SIG_KEY_ID, "DirectReference");
    properties.put(ConfigurationConstants.SIGNATURE_PARTS,
        "{Element}{http://schemas.xmlsoap.org/soap/envelope/}Body");
    properties.put(ConfigurationConstants.SIG_ALGO, "http://www.w3.org/2000/09/xmldsig#rsa-sha1");
    WSS4JInInterceptor interceptor = new WSS4JInInterceptor(properties);
    return interceptor;
  }

  public Properties wss4jInProperties() {
    Properties properties = new Properties();
    properties.put("org.apache.wss4j.crypto.merlin.provider", "org.apache.wss4j.common.crypto.Merlin");
    properties.put("org.apache.wss4j.crypto.merlin.keystore.type", truststoreType);
    properties.put("org.apache.wss4j.crypto.merlin.keystore.password", truststorePassword);
    properties.put("org.apache.wss4j.crypto.merlin.keystore.alias", truststoreAlias);
    properties.put("org.apache.wss4j.crypto.merlin.keystore.file", truststoreFile);
    return properties;
  }

}
```

# Test del servicio

Por último para probar que todo esta funcionando bien, cree el test de integración en el cliente. Recuerda tener el servidor en ejecución.

```java
@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = WebServiceConfiguration.class)
@SpringBootTest
public class DemoServiceEndpointIntegrationTest {

  @Autowired
  @Qualifier("recepcionWSClient")
  private DemoServiceEndpointPortType demoClient;

  @Test
  public void shouldResultOK() {
    String result = demoClient.status();
    assertEquals("OK", result);
  }
}
```

Esto ha sido todo por ahora, les dejo una copia del proyecto completo en repositorio de github.
  
<https://github.com/earth001/ws-security-spring-boot-cxf/>

Hasta la próxima.