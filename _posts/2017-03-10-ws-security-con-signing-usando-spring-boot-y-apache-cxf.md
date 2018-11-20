---
id: 214
title: WS-Security con signing usando Spring Boot y Apache CXF
date: 2017-03-10T02:07:52+00:00
author: Juan Moreno
layout: post
guid: http://proitcsolution.com.ve/?p=214
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

<img class="size-medium wp-image-222 aligncenter" src="https://proitcsolution.com.ve/wp-content/uploads/2017/03/server-wss-spring-180x300.png" alt="Proyecto del servidor" width="180" height="300" srcset="https://proitcsolution.com.ve/wp-content/uploads/2017/03/server-wss-spring-180x300.png 180w, https://proitcsolution.com.ve/wp-content/uploads/2017/03/server-wss-spring.png 273w" sizes="(max-width: 180px) 100vw, 180px" />

<p style="text-align: center;">
  Figura 1. Proyecto del servidor
</p>

A continuación muestro el archivo pom.xml con las dependencias usadas en el servidor:

<pre class="brush: xml; title: ; notranslate" title="">&lt;?xml version="1.0" encoding="UTF-8"?&gt;
&lt;project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd"&gt;
	&lt;modelVersion&gt;4.0.0&lt;/modelVersion&gt;

	&lt;groupId&gt;com.proitc&lt;/groupId&gt;
	&lt;artifactId&gt;ws-security-spring-boot-cxf-server&lt;/artifactId&gt;
	&lt;version&gt;0.0.1&lt;/version&gt;
	&lt;packaging&gt;jar&lt;/packaging&gt;

	&lt;name&gt;ws-security-spring-boot-cxf-server&lt;/name&gt;
	&lt;description&gt;Demo project for Spring Boot&lt;/description&gt;

	&lt;parent&gt;
		&lt;groupId&gt;org.springframework.boot&lt;/groupId&gt;
		&lt;artifactId&gt;spring-boot-starter-parent&lt;/artifactId&gt;
		&lt;version&gt;1.4.2.RELEASE&lt;/version&gt;
		&lt;relativePath /&gt;
	&lt;/parent&gt;

	&lt;properties&gt;
		&lt;project.build.sourceEncoding&gt;UTF-8&lt;/project.build.sourceEncoding&gt;
		&lt;project.reporting.outputEncoding&gt;UTF-8&lt;/project.reporting.outputEncoding&gt;
		&lt;java.version&gt;1.8&lt;/java.version&gt;
		&lt;cxf.version&gt;3.1.8&lt;/cxf.version&gt;
		&lt;wssj4.version&gt;1.6.19&lt;/wssj4.version&gt;
		&lt;apacheCommons.version&gt;3.5&lt;/apacheCommons.version&gt;
		&lt;jaxwsMavenPlugin.version&gt;2.4.1&lt;/jaxwsMavenPlugin.version&gt;
	&lt;/properties&gt;

	&lt;dependencies&gt;
		&lt;dependency&gt;
			&lt;groupId&gt;org.springframework.boot&lt;/groupId&gt;
			&lt;artifactId&gt;spring-boot-devtools&lt;/artifactId&gt;
		&lt;/dependency&gt;
		&lt;dependency&gt;
			&lt;groupId&gt;org.springframework.boot&lt;/groupId&gt;
			&lt;artifactId&gt;spring-boot-starter-web&lt;/artifactId&gt;
		&lt;/dependency&gt;
		&lt;!-- Apache CXF --&gt;
		&lt;dependency&gt;
			&lt;groupId&gt;org.apache.cxf&lt;/groupId&gt;
			&lt;artifactId&gt;cxf-rt-frontend-jaxws&lt;/artifactId&gt;
			&lt;version&gt;${cxf.version}&lt;/version&gt;
		&lt;/dependency&gt;
		&lt;dependency&gt;
			&lt;groupId&gt;org.apache.cxf&lt;/groupId&gt;
			&lt;artifactId&gt;cxf-rt-transports-http&lt;/artifactId&gt;
			&lt;version&gt;${cxf.version}&lt;/version&gt;
		&lt;/dependency&gt;
		&lt;dependency&gt;
			&lt;groupId&gt;org.apache.cxf&lt;/groupId&gt;
			&lt;artifactId&gt;cxf-rt-ws-security&lt;/artifactId&gt;
			&lt;version&gt;${cxf.version}&lt;/version&gt;
		&lt;/dependency&gt;
		&lt;dependency&gt;
			&lt;groupId&gt;org.apache.cxf&lt;/groupId&gt;
			&lt;artifactId&gt;cxf-rt-ws-policy&lt;/artifactId&gt;
			&lt;version&gt;${cxf.version}&lt;/version&gt;
		&lt;/dependency&gt;
		&lt;!-- Apache commons --&gt;
		&lt;dependency&gt;
			&lt;groupId&gt;org.apache.commons&lt;/groupId&gt;
			&lt;artifactId&gt;commons-lang3&lt;/artifactId&gt;
			&lt;version&gt;${apacheCommons.version}&lt;/version&gt;
		&lt;/dependency&gt;
		&lt;!-- Test --&gt;
		&lt;dependency&gt;
			&lt;groupId&gt;org.springframework.boot&lt;/groupId&gt;
			&lt;artifactId&gt;spring-boot-starter-test&lt;/artifactId&gt;
			&lt;scope&gt;test&lt;/scope&gt;
		&lt;/dependency&gt;
	&lt;/dependencies&gt;

	&lt;build&gt;
		&lt;plugins&gt;
			&lt;plugin&gt;
				&lt;groupId&gt;org.springframework.boot&lt;/groupId&gt;
				&lt;artifactId&gt;spring-boot-maven-plugin&lt;/artifactId&gt;
			&lt;/plugin&gt;
			&lt;plugin&gt;
				&lt;groupId&gt;org.apache.maven.plugins&lt;/groupId&gt;
				&lt;artifactId&gt;maven-surefire-plugin&lt;/artifactId&gt;
				&lt;configuration&gt;
					&lt;excludes&gt;
						&lt;exclude&gt;**/*IntegrationTest.java&lt;/exclude&gt;
					&lt;/excludes&gt;
				&lt;/configuration&gt;
			&lt;/plugin&gt;
		&lt;/plugins&gt;
	&lt;/build&gt;
	&lt;profiles&gt;
		&lt;profile&gt;
			&lt;id&gt;generate-wsdl&lt;/id&gt;
			&lt;activation&gt;
				&lt;property&gt;
					&lt;name&gt;generate-wsdl&lt;/name&gt;
				&lt;/property&gt;
			&lt;/activation&gt;
			&lt;build&gt;
				&lt;plugins&gt;
					&lt;plugin&gt;
						&lt;groupId&gt;org.apache.cxf&lt;/groupId&gt;
						&lt;artifactId&gt;cxf-java2ws-plugin&lt;/artifactId&gt;
						&lt;version&gt;${cxf.version}&lt;/version&gt;
						&lt;dependencies&gt;
							&lt;dependency&gt;
								&lt;groupId&gt;org.apache.cxf&lt;/groupId&gt;
								&lt;artifactId&gt;cxf-rt-frontend-jaxws&lt;/artifactId&gt;
								&lt;version&gt;${cxf.version}&lt;/version&gt;
							&lt;/dependency&gt;
							&lt;dependency&gt;
								&lt;groupId&gt;org.apache.cxf&lt;/groupId&gt;
								&lt;artifactId&gt;cxf-rt-frontend-simple&lt;/artifactId&gt;
								&lt;version&gt;${cxf.version}&lt;/version&gt;
							&lt;/dependency&gt;
						&lt;/dependencies&gt;
						&lt;executions&gt;
							&lt;execution&gt;
								&lt;id&gt;process-classes-endpoint&lt;/id&gt;
								&lt;phase&gt;process-classes&lt;/phase&gt;
								&lt;configuration&gt;
									&lt;className&gt;com.proitc.wss.endpoint.DemoServiceEndpoint&lt;/className&gt;
									&lt;genWsdl&gt;true&lt;/genWsdl&gt;
									&lt;verbose&gt;true&lt;/verbose&gt;
								&lt;/configuration&gt;
								&lt;goals&gt;
									&lt;goal&gt;java2ws&lt;/goal&gt;
								&lt;/goals&gt;
							&lt;/execution&gt;
						&lt;/executions&gt;
					&lt;/plugin&gt;
				&lt;/plugins&gt;
			&lt;/build&gt;
		&lt;/profile&gt;
	&lt;/profiles&gt;
&lt;/project&gt;
</pre>

&nbsp;

# Definición del servicio

El servicio que vamos a exponer es bastante sencillo, y contiene un solo método al que llamaremos `status`. Esta definido en la interfaz `DemoService` del paquete `com.proitc.wss.sei`.

<pre class="brush: java; title: ; notranslate" title="">package com.proitc.wss.sei;

import javax.jws.WebService;

@WebService(targetNamespace = "http://endpoint.wss.proitc.com/")
public interface DemoService {
	public String status();
}
</pre>

La implementación de la interfaz se encuentra en la clase `DemoServiceEndpoint`, donde para efectos de este ejemplo simplemente devolveremos &#8220;OK&#8221;. En caso que quisiéramos agregar más métodos simplemente los agregaremos a la interfaz.

# Configuración del servidor

La configuración del servidor se encuentra en la clase `WebServiceConfiguration`

<pre class="brush: java; title: ; notranslate" title="">@Configuration
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
		Map&amp;lt;String, Object&amp;gt; properties = new HashMap&amp;lt;&amp;gt;();
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
		Map&amp;lt;String, String&amp;gt; passwords = new HashMap&amp;lt;&amp;gt;();
		passwords.put(keystoreAlias, keystorePassword);
		return new ClientKeystorePasswordCallback(passwords);
	}

}
</pre>

Esta clase toma las propiedades `@Value` de los archivos de application.yml y application-dev.properties, en ellos están los datos del contexto, url del servicio y parámetros del keystore.

El método encargado de configurar la seguridad es `public WSS4JOutInterceptor wss4jOut()` este toma las propiedades del certificado y configura el interceptor de los mensajes salientes. Los [interceptores](http://cxf.apache.org/docs/interceptors.html) en Apache CXF se encargan de hacer transformaciones y validar los mensajes.

En la línea 62 y 63 se ve como configura la acción de firma y marca de tiempo de los mensajes.

# Estructura del cliente

En la figura 2 se observa la estructura del proyecto del cliente:

<img class="size-medium wp-image-228 aligncenter" src="https://proitcsolution.com.ve/wp-content/uploads/2017/03/client-wss-spring-163x300.png" alt="Estructura del proyecto del cliente" width="163" height="300" srcset="https://proitcsolution.com.ve/wp-content/uploads/2017/03/client-wss-spring-163x300.png 163w, https://proitcsolution.com.ve/wp-content/uploads/2017/03/client-wss-spring.png 297w" sizes="(max-width: 163px) 100vw, 163px" />

<p style="text-align: center;">
  Figura 2. Estructura del proyecto del cliente
</p>

<p style="text-align: left;">
  Las dependencias del cliente son la siguientes:
</p>

<pre class="brush: xml; title: ; notranslate" title="">&lt;?xml version="1.0" encoding="UTF-8"?&gt;
&lt;project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd"&gt;
	&lt;modelVersion&gt;4.0.0&lt;/modelVersion&gt;

	&lt;groupId&gt;com.proitc&lt;/groupId&gt;
	&lt;artifactId&gt;ws-security-spring-boot-cxf-client&lt;/artifactId&gt;
	&lt;version&gt;0.0.1&lt;/version&gt;
	&lt;packaging&gt;jar&lt;/packaging&gt;

	&lt;name&gt;ws-security-spring-boot-cxf-client&lt;/name&gt;
	&lt;description&gt;Demo project for Spring Boot&lt;/description&gt;

	&lt;parent&gt;
		&lt;groupId&gt;org.springframework.boot&lt;/groupId&gt;
		&lt;artifactId&gt;spring-boot-starter-parent&lt;/artifactId&gt;
		&lt;version&gt;1.4.2.RELEASE&lt;/version&gt;
		&lt;relativePath /&gt;
	&lt;/parent&gt;

	&lt;properties&gt;
		&lt;project.build.sourceEncoding&gt;UTF-8&lt;/project.build.sourceEncoding&gt;
		&lt;project.reporting.outputEncoding&gt;UTF-8&lt;/project.reporting.outputEncoding&gt;
		&lt;java.version&gt;1.8&lt;/java.version&gt;
		&lt;cxf.version&gt;3.1.8&lt;/cxf.version&gt;
		&lt;wssj4.version&gt;1.6.19&lt;/wssj4.version&gt;
		&lt;apacheCommons.version&gt;3.5&lt;/apacheCommons.version&gt;
		&lt;jaxwsMavenPlugin.version&gt;2.4.1&lt;/jaxwsMavenPlugin.version&gt;
	&lt;/properties&gt;

	&lt;dependencies&gt;
		&lt;dependency&gt;
			&lt;groupId&gt;org.springframework.boot&lt;/groupId&gt;
			&lt;artifactId&gt;spring-boot-devtools&lt;/artifactId&gt;
		&lt;/dependency&gt;
		&lt;dependency&gt;
			&lt;groupId&gt;org.springframework.boot&lt;/groupId&gt;
			&lt;artifactId&gt;spring-boot-starter-web&lt;/artifactId&gt;
		&lt;/dependency&gt;
		&lt;!-- Apache CXF --&gt;
		&lt;dependency&gt;
			&lt;groupId&gt;org.apache.cxf&lt;/groupId&gt;
			&lt;artifactId&gt;cxf-rt-frontend-jaxws&lt;/artifactId&gt;
			&lt;version&gt;${cxf.version}&lt;/version&gt;
		&lt;/dependency&gt;
		&lt;dependency&gt;
			&lt;groupId&gt;org.apache.cxf&lt;/groupId&gt;
			&lt;artifactId&gt;cxf-rt-transports-http&lt;/artifactId&gt;
			&lt;version&gt;${cxf.version}&lt;/version&gt;
		&lt;/dependency&gt;
		&lt;dependency&gt;
			&lt;groupId&gt;org.apache.cxf&lt;/groupId&gt;
			&lt;artifactId&gt;cxf-rt-ws-security&lt;/artifactId&gt;
			&lt;version&gt;${cxf.version}&lt;/version&gt;
		&lt;/dependency&gt;
		&lt;dependency&gt;
			&lt;groupId&gt;org.apache.cxf&lt;/groupId&gt;
			&lt;artifactId&gt;cxf-rt-ws-policy&lt;/artifactId&gt;
			&lt;version&gt;${cxf.version}&lt;/version&gt;
		&lt;/dependency&gt;
		&lt;!-- Apache commons --&gt;
		&lt;dependency&gt;
			&lt;groupId&gt;org.apache.commons&lt;/groupId&gt;
			&lt;artifactId&gt;commons-lang3&lt;/artifactId&gt;
			&lt;version&gt;${apacheCommons.version}&lt;/version&gt;
		&lt;/dependency&gt;
		&lt;!-- Test --&gt;
		&lt;dependency&gt;
			&lt;groupId&gt;org.springframework.boot&lt;/groupId&gt;
			&lt;artifactId&gt;spring-boot-starter-test&lt;/artifactId&gt;
			&lt;scope&gt;test&lt;/scope&gt;
		&lt;/dependency&gt;
	&lt;/dependencies&gt;

	&lt;build&gt;
		&lt;plugins&gt;
			&lt;plugin&gt;
				&lt;groupId&gt;org.springframework.boot&lt;/groupId&gt;
				&lt;artifactId&gt;spring-boot-maven-plugin&lt;/artifactId&gt;
			&lt;/plugin&gt;
			&lt;plugin&gt;
				&lt;groupId&gt;org.apache.maven.plugins&lt;/groupId&gt;
				&lt;artifactId&gt;maven-surefire-plugin&lt;/artifactId&gt;
				&lt;configuration&gt;
					&lt;excludes&gt;
						&lt;exclude&gt;**/*IntegrationTest.java&lt;/exclude&gt;
					&lt;/excludes&gt;
				&lt;/configuration&gt;
			&lt;/plugin&gt;
		&lt;/plugins&gt;
	&lt;/build&gt;
	&lt;profiles&gt;
		&lt;profile&gt;
			&lt;id&gt;generate-client&lt;/id&gt;
			&lt;activation&gt;
				&lt;property&gt;
					&lt;name&gt;generate-client&lt;/name&gt;
				&lt;/property&gt;
			&lt;/activation&gt;
			&lt;build&gt;
				&lt;plugins&gt;
					&lt;plugin&gt;
						&lt;groupId&gt;org.codehaus.mojo&lt;/groupId&gt;
						&lt;artifactId&gt;jaxws-maven-plugin&lt;/artifactId&gt;
						&lt;version&gt;${jaxwsMavenPlugin.version}&lt;/version&gt;
						&lt;configuration&gt;
							&lt;wsdlDirectory&gt;
								../client/src/main/resources/service-api-definition/
							&lt;/wsdlDirectory&gt;
							&lt;wsdlLocation&gt;/service-api-definition/*&lt;/wsdlLocation&gt;
							&lt;keep&gt;true&lt;/keep&gt;
							&lt;wsdlFiles&gt;
								&lt;wsdlFile&gt;DemoServiceEndpoint.wsdl&lt;/wsdlFile&gt;
							&lt;/wsdlFiles&gt;
							&lt;sourceDestDir&gt;src/main/java&lt;/sourceDestDir&gt;
							&lt;vmArgs&gt;
								&lt;vmArg&gt;-Djavax.xml.accessExternalSchema=all&lt;/vmArg&gt;
							&lt;/vmArgs&gt;
						&lt;/configuration&gt;
						&lt;executions&gt;
							&lt;execution&gt;
								&lt;goals&gt;
									&lt;goal&gt;wsimport&lt;/goal&gt;
								&lt;/goals&gt;
							&lt;/execution&gt;
						&lt;/executions&gt;
					&lt;/plugin&gt;
					&lt;plugin&gt;
						&lt;groupId&gt;org.codehaus.mojo&lt;/groupId&gt;
						&lt;artifactId&gt;build-helper-maven-plugin&lt;/artifactId&gt;
						&lt;executions&gt;
							&lt;execution&gt;
								&lt;id&gt;add-source&lt;/id&gt;
								&lt;phase&gt;generate-sources&lt;/phase&gt;
								&lt;goals&gt;
									&lt;goal&gt;add-source&lt;/goal&gt;
								&lt;/goals&gt;
								&lt;configuration&gt;
									&lt;sources&gt;
										&lt;source&gt;src/main/java&lt;/source&gt;
									&lt;/sources&gt;
								&lt;/configuration&gt;
							&lt;/execution&gt;
						&lt;/executions&gt;
					&lt;/plugin&gt;
				&lt;/plugins&gt;
			&lt;/build&gt;
		&lt;/profile&gt;
	&lt;/profiles&gt;
&lt;/project&gt;
</pre>

# Generación del cliente SOAP

Para generar el cliente vamos a necesitar el wsdl de los servicios, para crearlo basta con ejecutar el perfil generate-wsdl del pom.xml del servidor.
  
`$ mvn clean install -Pgenerate-wsdl -Dgenerate-wsdl`
  
Luego de hacerlo tendremos en la carpeta target/generated/wsdl el wsdl de los endpoints que tengamos para procesar.

El wsdl lo copiamos en la carpeta src/main/resources/service-api-definition, y creamos las clases del cliente ejecutando el perfil generate-client del pom.xml del cliente.
  
`$ mvn clean install -Pgenerate-client -Dgenerate-client`

# Configuración del cliente

La clase de configuración del cliente es similar a la del servidor WebServiceConfiguration, pero en este caso vamos a configurar es un interceptor entrante.

<pre class="brush: java; title: ; notranslate" title="">@Configuration
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
		Map&lt;String, Object&gt; properties = new HashMap&lt;&gt;();
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
</pre>

# Test del servicio

Por último para probar que todo esta funcionando bien, cree el test de integración en el cliente. Recuerda tener el servidor en ejecución.

<pre class="brush: java; title: ; notranslate" title="">@RunWith(SpringJUnit4ClassRunner.class)
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
</pre>

Esto ha sido todo por ahora, les dejo una copia del proyecto completo en repositorio de github.
  
<https://github.com/earth001/ws-security-spring-boot-cxf/>

Hasta la próxima.