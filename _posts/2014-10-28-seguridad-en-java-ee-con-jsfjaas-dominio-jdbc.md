---
title: Seguridad en Java EE con JSF/JAAS – Dominio JDBC
date: 2014-10-28T15:32:15+00:00
author: Juan Moreno
layout: post
comments: true
permalink: /seguridad-en-java-ee-con-jsfjaas-dominio-jdbc/
image: /wp-content/uploads/2014/10/lock-xxl.png
categories:
  - glassfish
  - jaas
  - java
  - javaee
  - security
---
## Descripción General

En el siguiente post presentaré un ejemplo práctico de configuración del _Java Authentication and Authorization Service (JAAS)_ API, a través de este API podemos aplicar seguridad a aplicaciones Java con poca configuración. Utilizaremos usuarios y grupos de seguridad para definir nuestro dominio.

## Definiendo JDBC

JAAS permite definir dominios administrativos, de archivos, por certificado, JDBC y personalizados, en este ejemplo presentaré la configuración básica para JDBC. La plataforma que utilizaremos será:

  * **IDE**: Netbeans 8.0.1
  * **JDK**: 1.7.0_67
  * **Servidor**: Glassfish 4.1
  * **BD**: MySQL 5.5.8

La distribución de archivos en nuestra aplicación se observan en la figura 1.

![Figura 1. Distribución de archivos en el proyecto.](/wp-content/uploads/2014/10/post1_1.png)

Figura 1. Distribución de archivos en el proyecto.

Contaremos con dos directorios protegidos _**protected**_, al que podrán acceder los usuarios del grupo de _registereduser_ e _invitedguest_, y _**registered**_ al que sólo podrán ingresar los usuarios del grupo _registereduser_.
  
En nuestra BD tendremos dos tablas _**credentials**_ con los usuarios y **groups** con los grupos.

![Figura 2. Tablas de autenticación.](/wp-content/uploads/2014/10/post1_2.png)

Figura 2. Tablas de autenticación.

Lo primero que haremos será configurar nuestro recurso y pool de conexión JDBC. Para realizar la conexión con mysql se debe cargar al servidor el driver JDBC.
  
En este caso para _MySQL_ se puede descargar de la url <http://dev.mysql.com/downloads/connector/j/5.1.html>, y luego copiamos el _.jar_ a la ruta _**glassfish-4.1\glassfish\lib**_ y reiniciamos el servidor.

### Configuración de panel de Administración de Glassfish

En el panel de administración de glassfish accedemos a la ruta _Resources->JDBC->Connection Pool_, allí marcamos _New_ para crear un nuevo pool.
  
Para el ejemplo lo llamaremos _mydb_ donde los parámetros de configuración por pestaña son:

#### General:

  * **Pool Name**: mydb
  * **Resource Type:** javax.sql.DataSource
  * **Datasource Classname:** com.mysql.jdbc.jdbc2.optional.MysqlDataSource

![Figura 3. Configuración del Pool de Conexión MySQL](/wp-content/uploads/2014/10/post1_3.png)

Figura 3. Configuración del Pool de Conexión MySQL

#### Additional Properties:

  * **User**: root
  * **Password**: root
  * **DatabaseName**: mydb
  * **ServerName**: 127.0.0.1
  * **URL**: jdbc:mysql://localhost:3306/mydb

Nota: Si la propiedad no se encuentra la podemos agregar.

Una vez configurado esto validamos que tengamos acceso a nuestra BD haciendo ping.

![Figura 4. Ping satisfactorio.](/wp-content/uploads/2014/10/post1_4.png)

Figura 4. Ping satisfactorio.

### Configuración del recurso JDBC

Para configurar el recurso JDBC seguimos la ruta en glassfish _Resources->JDBC->JDBC Resources_, marcamos new y creamos la conexión al pool definido anteriormente.

![Figura 5. Configuración recurso JDBC](/wp-content/uploads/2014/10/post1_5.png)

Figura 5. Configuración recurso JDBC

Por último nos falta configurar nuestro domino de seguridad, la configuración se hace en _Configurations->Security->Realms_, una vez allí podemos crear un nuevo dominio o reutilizar uno existente, en este ejemplo usaremos el dominio _jdbcRealm_, la configuración es la siguiente:

![Figura 6. Configuración de jdbcRealm](/wp-content/uploads/2014/10/post1_6.png)

Figura 6. Configuración de jdbcRealm

#### Properties:

  * **JAAS Context**: jdbcRealm
  * **JNDI**: jdbc/mydb
  * **User Table**: Credentials
  * **User Name Column**: username
  * **Password Column**: passwd
  * **Group Name Column**: groupname
  * **Password Encryption Algorithm**: none
  * **Database User**: root
  * **Database Password**: root
  * **Digest Algorithm**: none
  * **Charset**: UTF-8

Una vez realizada toda la configuración procedemos a programar nuestra aplicación; explicaré los archivos más importantes:

#### Archivo de configuración web.xml

```xml
<web-app version="3.1" xmlns="http://xmlns.jcp.org/xml/ns/javaee" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://xmlns.jcp.org/xml/ns/javaee http://xmlns.jcp.org/xml/ns/javaee/web-app_3_1.xsd">
  <context-param>
    <param-name>javax.faces.PROJECT_STAGE</param-name>
    <param-value>Development</param-value>
  </context-param>
  <servlet>
    <servlet-name>Faces Servlet</servlet-name>
    <servlet-class>javax.faces.webapp.FacesServlet</servlet-class>
    <load-on-startup>1</load-on-startup>
  </servlet>
  <servlet-mapping>
    <servlet-name>Faces Servlet</servlet-name>
    <url-pattern>/faces/*</url-pattern>
  </servlet-mapping>
  <session-config>
    <session-timeout>
      30
    </session-timeout>
  </session-config>
  <welcome-file-list>
    <welcome-file>index.html</welcome-file>
  </welcome-file-list>
  <security-constraint><!--Configuración de seguridad-->
    <web-resource-collection>
      <web-resource-name>
        Paginas protegidas
      </web-resource-name>
      <url-pattern>/faces/protected/*</url-pattern><!--Directorio restringido-->
      <url-pattern>/protected/*</url-pattern><!--Patron de páginas-->
    </web-resource-collection>
    <auth-constraint><!--Grupos permitidos -->
      <role-name>registereduser</role-name>
      <role-name>invitedguest</role-name>
    </auth-constraint>
  </security-constraint>
  <security-constraint>
    <web-resource-collection>
      <web-resource-name>
        Paginas protegidas
      </web-resource-name>
      <url-pattern>/faces/registered/*</url-pattern>
      <url-pattern>/registered/*</url-pattern>
    </web-resource-collection>
    <auth-constraint>
      <role-name>registereduser</role-name>
    </auth-constraint>
  </security-constraint>
  <login-config>
    <auth-method>FORM</auth-method><!--Método de autenticación-->
    <realm-name>jdbcRealm</realm-name><!--Nombre de dominio-->
    <form-login-config>
      <form-login-page>/login.html</form-login-page><!--Página de login-->
      <form-error-page>/noautorizado.html</form-error-page><!--Página de error de autenticación-->
    </form-login-config>
  </login-config>
  <security-role><!--Roles de autenticación-->
    <role-name>registereduser</role-name>
  </security-role>
  <security-role>
    <role-name>invitedguest</role-name>
  </security-role>
</web-app>
```

En configuramos los directorios protegidos y los grupos permitidos. Con indicamos el tipo de login (form, basic…), el dominio y las páginas de login, por último con configuramos los roles.

#### Archivo de configuración sun-web.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE sun-web-app PUBLIC "-//Sun Microsystems, Inc.//DTD GlassFish Application Server 3.0 Servlet 3.0//EN" "http://www.sun.com/software/appserver/dtds/sun-web-app_3_0-0.dtd">
<sun-web-app error-url="">
  <security-role-mapping><!--Mapeo de roles y grupos-->
    <role-name>invitedguest</role-name>
    <group-name>invitedguest</group-name>
  </security-role-mapping>
  <security-role-mapping>
    <role-name>registereduser</role-name>
    <group-name>registereduser</group-name>
  </security-role-mapping>
  <class-loader delegate="true"/>
  <jsp-config>
    <property name="keepgenerated" value="true">
      <description>Keep a copy of the generated servlet class' java code.</description>
    </property>
  </jsp-config>
</sun-web-app>
```

El archivo _sun-web.xml_ es propio de glassfish, en caso de que usemos otro servidor las etiquetas pueden cambiar, aquí mapeamos los roles y los grupos con .

#### Archivo Index.html

```html
<html>
<head>
  <title>Inicio</title>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body>
Click <a href="faces/protected/bienvenida.xhtml"> en este link
</a> para acceder a información protegida
Click <a href="faces/registered/bienvenida.xhtml"> en este link
</a> solo para usuarios registrados
</body>
</html>
```
![Figura 7. Index.html](/wp-content/uploads/2014/10/post1_7.png)

Figura 7. Index.html

En el archivo index tenemos dos hipervínculos a archivos de los directorios protegidos, con nuestra configuración al marcar uno de ellos se nos solicitará el login, nótese que la extensión es html, pero bien puede ser jsp o xhtml.

#### Archivo login.html

```html
<html>
<head>
  <title>Formulario de login</title>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body>
<form method="post" action="j_security_check">
  </table>
  <tr>
    <td>Nombre: </td>
    <td><input type="text" name="j_username"/></td>
  </tr>
  <tr>
    <td>Contraseña: </td>
    <td><input type="text" name="j_password"/></td>
  </tr>
  </table>
  <input type="submit" value="Login">
</form>
</body>
</html>
```

El archivo de login define la autenticación del usuario e igualmente la extensión es html, pero puede ser jsp o xhtml, los parámetros j\_security\_check, j\_username y j\_password son estándares de JAAS y deben mantenerse para la autenticación.

#### Archivo bienvenida.xhtml

```xml
<?xml version='1.0' encoding='UTF-8' ?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:h="http://xmlns.jcp.org/jsf/html">
  <h:head>
    <title>Bienvenida</title>
  </h:head>
  <h:body>
    <h:form>
      Bienvenida Usuario Registrado
      Acceso concedido
      Usuario: #{usuario.nombre}
      <h:commandLink value="Logout" actionListener="#{usuario.logout()}" action="bienvenida"/>
    </h:form>
  </h:body>
</html>
```

![Figura 8. Bienvenida.xhtml](/wp-content/uploads/2014/10/post1_8.png)

Figura 8. Bienvenida.xhtml

Este archivo se mantuvo igual para ambos dominios ahora bien se agregó un hipervínculo para logout.

#### Archivo Usuario.java

```java
import java.io.IOException;
import java.io.Serializable;
import java.util.logging.Level;
import java.util.logging.Logger;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;
import javax.faces.context.ExternalContext;
import javax.faces.context.FacesContext;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

@ManagedBean(name = "usuario")
@SessionScoped
public class Usuario implements Serializable {

  private String nombre;

  public String getNombre() {
    if (nombre == null) {
      getDatosUsuario();
    }
    return nombre == null ? "" : nombre;
  }

  public void setNombre(String nombre) {
    this.nombre = nombre;
  }
  /**
   * Obtiene el nombre del usuario de la sesión
   */
  private void getDatosUsuario() {
    ExternalContext context = FacesContext.getCurrentInstance().getExternalContext();
    Object objPeticion = context.getRequest();
    if (!(objPeticion instanceof HttpServletRequest)) {
      System.out.println("Error objeto es: "
          + objPeticion.getClass().toString());
      return;
    }
    HttpServletRequest peticion = (HttpServletRequest) objPeticion;
    nombre = peticion.getRemoteUser();
    if (nombre == null) {
      logout();
    }
  }
  /**
   * Invalida la Sesión y redigiré a la página de inicio
   */
  public void logout() {
    ExternalContext ec = FacesContext.getCurrentInstance().getExternalContext();
    ec.invalidateSession();
    try {
      ec.redirect(ec.getRequestContextPath());
    } catch (IOException ex) {
      Logger.getLogger(Usuario.class.getName()).log(Level.SEVERE, null, ex);
    }
  }
} 
```

En el _Bean_ Usuario se usan los métodos _getDatosUsuario_ y logout para obtener los datos del usuario y cerrar sesión.

## Conclusión

Para concluir el post quiero enfatizar que es sólo un ejemplo básico, el nivel de parámetros de configuración y potencial que podemos aprovechar de JAAS es muy amplio.

Pueden descargar una copia completa del proyecto y definición de la base de datos del repositorio github <https://github.com/earth001/Ejercicios-JavaEE-Seguridad>.

**UPDATE IMPORTANTE**: Esta post tienes fines didacticos, es importante que las contraseñas **siempre** se guarden en **encriptadas** en la base de datos, para ello se deben escoger los algoritmos de encriptación y digest en el jdbcRealm.  