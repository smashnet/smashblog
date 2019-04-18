---
layout: post
author: nico
title: Microservices mit CherryPy Teil 1 - URL Routing
subtitle: Der richtige Dispatcher
category: article
published: true
---
In diesem Blogpost möchte ich gerne meine Erfahrungen aus der Entwicklung eines Microservice basierten Kleinprojekts teilen. Als technische Basis der einzelnen Services kommt [CherryPy](https://cherrypy.org/) zum Einsatz.

Während des Projekts bin ich auf mehrere Themen gestoßen, die ich gerne vorstellen möchte, und zu denen es jeweils einen eigenen Blogpost geben wird:

* Teil 1: URL-Routing
* Teil 2: Redis zur Inter-Service-Kommunikation
* Teil 3: CORS mit CherryPy

Meine Erfahrungen die ich mit CherryPy zum Thema **URL-Routing** gemacht habe, stelle ich in diesem Blogpost vor.

### URL-Routing mit CherryPy
Für jemanden wie mich, der die letzten vier Jahre als Product Owner und weniger als Entwickler gearbeitet hat, sind bereits vermeintliche Basics zu Erfolgserlebnissen geworden. Dazu gehört zunächst das Thema URL-Routing.

Generell braucht es in jedem Service Verbindungen zwischen den API-Endpunkten  und entsprechenden internen Funktionen, die die Anfragen an diese Endpunkte verarbeiten, wie z.B.:

| API-Endpunkt              | Interne Funktion             |
|---------------------------|------------------------------|
| `your.tld/members/{uuid}` | `getMemberInformation(uuid)` |

In CherryPy gibt es dafür diverse _Dispatcher_, die diese Verbindung auf verschiedene Arten herstellen:

* `DefaultDispatcher`
* `RoutesDispatcher`
* `MethodDispatcher`

#### DefaultDispatcher

Wird bei der Konfiguration von CherryPy nicht explizit ein bestimmter Dispatcher gewählt, so kommt der `DefaultDispatcher` zum Einsatz. Dieser Dispatcher interpretiert die URL als Baumstruktur. Meine Anwendung könnte also z.B. wie folgt aufgebaut sein:

![]({{ '/assets/images/cherrypy-url-routing/fig1.svg' | absolute_url }})

Um das gezeigte Beispiel nun mit CherryPy umzusetzen, brauchen wir zwei Dinge:

* Eine Klasse, deren Methoden das Handling für `/`, `/admin` und `/album` bereitstellen
* Das Mounting dieser Klasse in CherryPys URL-Baumstruktur

Schauen wir uns zunächst an, wie eine solche Klasse aussehen könnte:

```python
class SimpleWebGallery(object):
    @cherrypy.expose
    def index(self):
        return "Welcome to my index site!"

    @cherrypy.expose
    def admin(self):
        return "Let's administrate things!"

    @cherrypy.expose
    def album(self):
        return "My album!"
```

Die Klasse enthält also Methoden, die nach der URL-Struktur benannt sind, mit der Ausnahme von `/`, dessen Methode schlicht `index` heißt.

---
**Hinweis**
Um Zugriffe auf nicht definierte URLs abzufangen, kann die Methode `default` genutzt werden, die so gesehen als Catch All fungiert.

---

Zum jetzigen Zeitpunkt weiß CherryPy noch nicht, auf welcher Ebene `index` einzusortieren ist. Dies passiert nun beim Mounting unserer Klasse in CherryPy.

```python
cherrypy.quickstart(SimpleWebGallery(), '/', conf)
```

Dieser Befehl sorgt dafür, dass unsere Webapp `SimpleWebGallery` im Verzeichnisbaum auf den Root `/` gemappt wird, und damit folgendes Mapping hergestellt wird:

| API-Endpunkt             | Interne Funktion             |
|--------------------------|------------------------------|
| `/`                      | `SimpleWebGallery().index()` |
| `/admin`                 | `SimpleWebGallery().admin()` |
| `/album`                 | `SimpleWebGallery().album()` |

---
**Als Beispiel zur Verdeutlichung**

```python
cherrypy.quickstart(SimpleWebGallery(), '/foo', conf)
```

würde folgendes Mapping bewirken:

| API-Endpunkt             | Interne Funktion             |
|--------------------------|------------------------------|
| `/foo`                   | `SimpleWebGallery().index()` |
| `/foo/admin`             | `SimpleWebGallery().admin()` |
| `/foo/album`             | `SimpleWebGallery().album()` |

---

Rufen wir jetzt also `http://localhost:8080/` auf, so wird das Ergebnis der folgenden Methode ausgeliefert.

```python
@cherrypy.expose
def index(self):
    return "Welcome to my index site!"
```

##### Tiefer in den Baum

Der nächste Schritt ist interessanter. Meist bestehen Bereiche aus mehreren Sektionen, die sich um verschiedene Dinge kümmern, sprich die Teilbäume sind in der Regel tiefer. In meinem Beispiel müssen Alben und die darin enthaltenen Bilder und Subscriptions administriert werden. Wir haben also folgenden Aufbau:

![]({{ '/assets/images/cherrypy-url-routing/fig2.svg' | absolute_url }})

Wie wir jetzt z.B. an `/admin/album/{uuid}` kommen, ist wesentlich spannender, denn hier bietet CherryPy uns zwei Möglichkeiten. Auf diese zwei Arten des Routings möchte ich nur kurz eingehen, da sie zwar ihre Daseinsberechtigung haben, aber aus meiner Sicht den Code nur unverständlicher und schwerer wartbar gemacht haben.

1. Weitere Pfadbestandteile als Parameter in der Funktion entgegennehmen.
2. Auswerten von `*args` und `**kwargs`

In **Möglichkeit 1** werden alle _weiteren_ URL-Bestandteile als Parameter der entsprechenden Funktion übergeben. Wir müssen also bei der Implementierung antizipieren, wie viele weitere Bestandteile wir erwarten.

*Beispiel zu 1. für `/admin/album/{uuid}`*
Die Methode `admin` bekommt hier zwei Parameter übergeben, da hinter `/admin` zwei weitere URL-Bestandteile folgen. Diese Parameter müssen nun in `admin` validiert und ausgewertet werden:

```python
@cherrypy.expose
def admin(self, section, uuid):
    if section == "album" and isValidUUID(uuid):
        return "You requested the admin page for album %s" % uuid
    return "Unknown URL section or invalid UUID"
```

Die Implementierung von `admin` kann also beliebig komplex werden, je tiefer sich meine Web-Anwendung verschachtelt.

In **Möglichkeit 2** werden die weiteren URL-Bestandteile als Liste `*args`an meine Methode `admin` übergeben.

*Beispiel zu 2. für `/admin/album/{uuid}`*
```python
@cherrypy.expose
def admin(self, *args, **kwargs):
    if len(args) == 2 and args[0] == "album" and isValidUUID(args[1]):
        return "You requested the admin page for album %s" % uuid
    return "No handling for this amount of URL parameters or unknown URL section or invalid UUID"
```
Auch diese Methode endet ab einer gewissen Tiefe in extrem unübersichtlichem und nicht direkt einleuchtendem Code.

Allgemein finde ich den `DefaultDispatcher` in einfachen Szenarien gut nutzbar, allerdings sind Behandlungen für tiefere Teile der URL unschön.

Zum Schluss ein Komplettbeispiel für den DefaultDispatcher:

```python
import cherrypy

def init_service():
    # Do init stuff
    return

def cleanup():
    # Do cleanup stuff
    return

class SimpleWebGallery(object):
    @cherrypy.expose
    def index(self):
        return "Welcome to my index site!"

    @cherrypy.expose
    def admin(self, section=None, uuid=None):
        if section == None and uuid == None:
            return "Let's administrate things!"
        if section == "album" and isValidUUID(uuid):
            return "You requested the admin page for album %s" % uuid
        return "Unknown URL section or invalid UUID"

    @cherrypy.expose
    def album(self):
        return "My album!"


if __name__ == '__main__':
    conf = {
        '/': {
            'tools.sessions.on': False,
            'tools.staticdir.root': os.path.abspath(os.getcwd())
        },
        '/static': {
            'tools.staticdir.on': True,
            'tools.staticdir.dir': './static'
        }
    }

    cherrypy.server.socket_host = '0.0.0.0'
    cherrypy.server.socket_port = 8080

    cherrypy.engine.subscribe('start', init_service)
    cherrypy.engine.subscribe('stop', cleanup)

    webapp = SimpleWebGallery()

    cherrypy.quickstart(webapp, '/', conf)
```

#### MethodDispatcher
Einen ähnlichen Ansatz verfolgt der `MethodDispatcher` (MD). Hier wird in CherryPy ein Mounting Tree aufgebaut, der - analog zum Vorgehen beim `DefaultDispatcher` - bestimmt, welche Funktionen für welche API-Endpunkte verantwortlich sind.
Im Speziellen nutzt der MD eine explizitiere Unterscheidung zwischen den verschiedenen Requestmethoden `GET`, `POST`, `PUT`, `DELETE` etc.

**Beispiel**
```python
  conf = {
      [...]
      '/photos': {
          'request.dispatch': cherrypy.dispatch.MethodDispatcher()
      },
      '/rawcontent': {
          'request.dispatch': cherrypy.dispatch.MethodDispatcher()
      }
  }

  webapp = PhotoServiceRoot()                  # "/" -> PhotoServiceRoot()
  webapp.photos = PhotoServicePhotos()         # "/photos" -> PhotoServicePhotos()
  webapp.rawcontent = PhotoServiceRawContent() # "/rawcontent" -> PhotoServiceRawContent()

  cherrypy.quickstart(webapp, '/photo-service', conf)
```

In der Variable `webapp` wird bestimmt, welche _Klassen_ für welche Teilbäume des URL-Pfades verantwortlich sind. Diese Klassen enthalten dann jeweils die folgenden Methoden:

```python
def GET(self):
    [...]

def POST(self):
    [...]

def PUT(self):
    [...]
[...]
```

---
**Hinweis**
Im Gegensatz zum `DefaultDispatcher` stellen also **nicht** die _Methoden_ in `webapp` die Implementierung des Handling, **sondern** die _Klassen_, die den URL-Pfad benannten Attributen zugewiesen sind.

---

Im gezeigten Beispiel wird ein Mounting Tree

![]({{ '/assets/images/cherrypy-url-routing/fig3.svg' | absolute_url }})

aufgebaut und in der letzten Zeile am Einstiegspunkt `/photo-service` eingebunden. Der Service reagiert also entsprechend auf:

![]({{ '/assets/images/cherrypy-url-routing/fig4.svg' | absolute_url }})

Die Besonderheit des MD liegt nun darin, dass die Methoden `GET`, `POST`, `PUT` etc. als explizite Funktionen in den Klassen vorhanden sein müssen und automatisch verbunden werden, also:

| API-Endpunkt                         | Interne Funktion            |
|--------------------------------------|-----------------------------|
| `POST` `/photo-service/photos`       | `PhotoServicePhotos.POST()` |
| `GET` `/photo-service/photos/{uuid}` | `PhotoServicePhotos.GET()`  |
| ...                                  | ...                         |

Was auf den ersten Blick ziemlich praktisch aussieht, hat im Endeffekt ähnliche Probleme wie unsere erste Variante mit dem `DefaultDispatcher`. Eine Klasse oder Funktion ist für einen gesamten Teilbaum verantwortlich, Unterscheidungen bei mehreren Parametern müssen in den Funktionen getroffen werden. Dadurch steckt viel Logik tief im Code, was wenig deklarativ und somit nicht auf den ersten Blick ersichtlich ist.

#### RoutesDispatcher

Der `RoutesDispatcher` erlaubt es uns, Routen anhand von URL-Templates anzugeben und direkt auf eine konkrete Funktion zu leiten. Der große Vorteil ist, dass die weiteren Bestandteile der URL expliziter im Code angegeben sind und nicht programmatisch aus Parametern herausgefischt werden müssen. An einem Beispiel wird dies schnell ersichtlich:

```python
class SimpleWebGallery(object):
  def getRoutesDispatcher(self):
    d = cherrypy.dispatch.RoutesDispatcher()

    d.connect('home_index', '/',                # URL
              controller=HomeController(),      # Controller class
              action='index',                   # Controller method to invoke
              conditions=dict(method=['GET']))  # On method "GET"

    d.connect('admin_album_index', '/admin/album/{uuid}',
              controller=AdminController(),
              action='album_index',
              conditions=dict(method=['GET']))

    return d
```

Wir können nun für jede URL eine direkte Verbindung zu einer Funktion aufbauen und haben für jeden API-Endpunkt einen konkreten Eintrag im Dispatcher, dadurch bleibt der Code wesentlich übersichtlicher und damit wartbarer. Weiterhin können variable Anteile in der URL direkt mit `{}` kenntlich gemacht werden. Diese werden dann als entrechend benamte Variablen an die unter `action` angegebene Funktion weitergereicht.

Zum Schluss noch ein lauffähiges Minimalbeispiel für den `RoutesDispatcher`:
```python
import os
import cherrypy

def init_service():
	# Do init stuff
  return

def cleanup():
	# Do cleanup stuff
  return

class HomeController(object):
  @cherrypy.expose
  def hello(self, user):
      return "Hello %s!" % user

class SimpleWebGallery(object):
  def getRoutesDispatcher(self):
    d = cherrypy.dispatch.RoutesDispatcher()

    d.connect('say_hello', '/user/{user}',
              controller=HomeController(),
              action='hello',
              conditions=dict(method=['GET']))

    return d

if __name__ == '__main__':
  app = SimpleWebGallery()

  conf = {
  	'/': {
  		'tools.sessions.on': False,
		'request.dispatch': app.getRoutesDispatcher(),
  		'tools.staticdir.root': os.path.abspath(os.getcwd())
  	},
  	'/static': {
  		'tools.staticdir.on': True,
  		'tools.staticdir.dir': './static'
  	}
  }

  cherrypy.server.socket_host = '0.0.0.0'
  cherrypy.server.socket_port = 8080

  cherrypy.engine.subscribe('start', init_service)
  cherrypy.engine.subscribe('stop', cleanup)

  cherrypy.quickstart(None, '/', conf)

```

Rufen wir nun lokal `http://localhost:8080/user/world` auf, so werden wir mit einem herzlichen "Hello world!" begrüßt.

### Fazit
Es sind eine Menge praktische Kleinigkeiten in der Implementierung, die letztlich die meiste Zeit kosten. Eine dieser Kleinigkeiten ist das URL-Routing. CherryPy bietet dazu diverse Wege an, die aber nicht unbedingt alle zu übersichtlichem und wartbarem Code führen. Der `RoutesDispatcher` ist zwar leider schlecht dokumentiert, bietet aus meiner Sicht aber aktuell die expliziteste Form des Routing an und fördert damit verständlichen Code.
