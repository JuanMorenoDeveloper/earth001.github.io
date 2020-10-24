---
title: How to use dependency injection with Spring Framework
date: 2020-09-29T22:49:00+03:00
author: Juan Moreno
layout: post
comments: true
permalink: /how-to-use-dependency-injection-with-spring/
excerpt: Do you want to use Spring to inject dependencies?
background: '/wp-content/uploads/2017/12/spring-logo.png'
categories:
  - spring
---

# Overview

Dependency injection is a software development technique where objects are not responsible for initializing their dependencies, instead, they are provided through another object. When we use Spring, that object is the IoC container that is represented by [`ApplicationContext`](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/context/ApplicationContext.html) and [`BeanFactory`](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/beans/factory/BeanFactory.html) interfaces which are provided by the [`spring-core`](https://search.maven.org/search?q=g:org.springframework%20AND%20a:spring-core) and [`spring-beans`](https://search.maven.org/search?q=g:org.springframework%20AND%20a:spring-beans) dependencies.

In this article, we'll see different types of dependency injection using Spring.

# Types of dependency injection

With the Spring's IoC container we can use three injections types: constructor, setter, and field.

1. **Constructor**: In this case, the container uses the constructor class to pass the dependencies. In most cases, this is the best way; we can found more details in this [post by Oliver Drotbohm (Spring Data)](http://olivergierke.de/2013/11/why-field-injection-is-evil/) or in [Spring Framework documentation](https://docs.spring.io/spring-framework/docs/current/spring-framework-reference/core.html#beans-constructor-injection).

2. **Setter**: In this type, the container uses the setter methods to assign the dependencies. This is recommended for optional dependencies.

3. **Field**: In this case, a method is not required to assign the dependency but it is assigned through the reflection API. It is used for very basic cases but is usually not recommended.

# Example

So, let's create a simple `DatabaseService` class with a `DataSource` and `AuditService` dependencies to explore different types of injections with Spring:

```java
public class DatabaseService {

  private DataSource dataSource;
  private AuditService auditService;

  public DatabaseService (DataSource dataSource) {
    this.dataSource = dataSource;
  }

  public void setAuditService (AuditService auditService) {
    this.auditService = auditService;
  }
}

public class DataSource {

  private String driverClassName;
  private String url;
  private String username;
  private String password;

  //getter and setters
}

public class AuditService {

  private String level;
  //constructor, getter and setters 
}
```
## Dependencies

To use the IoC Spring container we need to add the following dependency to our Maven project:

```xml
<dependency>
    <groupId>org.springframework</groupId>
    <artifactId>spring-context</artifactId>
    <version>5.2.9.RELEASE</version>
</dependency>
```
The most recent versions can be found in [Maven Central](https://search.maven.org/search?q=g:org.springframework%20AND%20a:spring-core).

# Setup

To configure dependency injection with Spring we can use JavaConfig or XML.

Let's explore how JavaConfig works. First, let's review some Spring annotations:

* `@Configuration`: We use it to mark that this class will initialize beans

* `@ComponentScan`: To search for beans with Spring annotations in a specific package

* `@Bean`: In methods that initialize a bean

* `@Component`, `@Service`, `@Repository`: To mark classes that will be scanned.

* `@Autowire`: For bean injection.

* `@Inject`: This is not a Spring annotation, but we can use it to inject beans with Spring. This annotation is part of the JSR-330 specification.

Now let's see these annotations in action:

```java
@Configuration
@ComponentScan (basePackages = {"ve.com.proitcsolution.service"})
public class JavaConfig {

  @Bean
  public DataSource dataSource () {
    DataSource dataSource = new DataSource ();
    dataSource.setDriverClassName ("com.mysql.jdbc.Driver");
    dataSource.setUrl ("jdbc: mysql: //127.0.0.1/");
    dataSource.setUsername ("production username");
    dataSource.setPassword ("production password");
    return dataSource;
  }

  @Bean
  public AuditService auditService () {
    AuditService auditService = new AuditService ("INFO");
    return auditService;
  }
}
```

As we can see, in the `JavaConfig` class we look for beans in package `"ve.com.proitcsolution.service"` and also initialize `DataSource` and `AuditService` beans.

Now, let's update our previous `DataBaseService` with `@Service` to mark it as a Spring bean (scannable), and also add `@Autowired` to the injection points (setter).

```java
@Service
public class DatabaseService {

  private DataSource dataSource;
  private AuditService auditService;

  public DatabaseService (DataSource dataSource) {
    this.dataSource = dataSource;
  }

  @Autowired
  public void setAuditService (AuditService auditService) {
    this.auditService = auditService;
  }
}
```

Note that we don't have the `@Autowired` annotation over our constructor, this is optional since Spring 4.3 when our bean has only one constructor.

# Testing

Finally, let's write a test to verify the beans injection:

```java
@SpringJUnitConfig(JavaConfig.class)
public class DependencyInjectionJavaConfigTest {

  @Inject
  DatabaseService databaseService;
  @Inject
  DataSource dataSource;
  @Inject
  AuditService auditService;

  @Test
  public void shouldBeDatabaseServiceNotNull() {
    assertThat(databaseService).isNotNull().hasNoNullFieldsOrProperties();
  }

  @Test
  public void shouldBeDataSourceNotNull() {
    assertThat(dataSource).isNotNull();
  }

  @Test
  public void shouldBeAuditServiceNotNull() {
    assertThat(auditService).isNotNull();
  }

}
```
When we run it we'll see that the IoC container initializes all the beans and dependencies correctly.

# Conclusion

In this tutorial, we saw an example of how to use dependency injection with Spring using JavaConfig.

The complete code is available over on [Github](https://github.com/JuanMorenoDeveloper/spring-di-examples).