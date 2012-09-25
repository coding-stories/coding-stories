---
layout: post
title: "equals() et java.lang.reflect.Proxy"
date: 2010-08-24 07:17
comments: true
categories: [java, proxy]
---

[java.lang.reflect.Proxy](http://download.oracle.com/javase/6/docs/api/java/lang/reflect/Proxy.html) qui a été ajouté dans la bibliothèque standard à partir de Java 1.3 est un de mes jouets préférés. Cette classe permet de créer dynamiquement des instances qui implémentent n’importe quelle liste d’interfaces.

Prenons un exemple :

{% codeblock lang:java %}
public interface UserAccount
{
    Credentials getCredentials();
    void updateCredentials(Credentials credentials);
    void suspend();
    void resume();
}
{% endcodeblock %}

Avec une classe Proxy on peut fabriquer une instance de `UserAccount qui loggue les appels aux différentes méthodes :

{% codeblock lang:java %}
public UserAccount wrapBad(final UserAccount realAccout)
{
    InvocationHandler handler = new InvocationHandler() {
        public Object invoke(Object proxy, Method method, Object[] args) throws Throwable
        {
            try {
                method.invoke(realAccount, args);
            } finally {
                LOGGER.info(method + " called with arguments " + Arrays.toString(args));
            }
        }
    };
    return Proxy.newProxyInstance(UserAccount.class.getClassLoader(),
        new Class[] { UserAccount.class }, handler);
}
{% endcodeblock %}

Et là, formidable, chaque appel produit maintenant une ligne de log. Sauf que si on s’arrête là on s’expose à un gag :

{% codeblock %}
UserAccount account = wrapBad(realAccount);
System.out.println(account.equals(account)); /* <-- affiche false */
{% endcodeblock %}

Et là on se rend compte qu’on a cassé le contrat de `Object.equals()`. `Object.equals() définit une relation d’équivalence et par conséquent cette relation est réflexive, comme le précise d’ailleurs la javadoc :

{% blockquote %}
It is reflexive: for any non-null reference value x, x.equals(x) should return true.
{% endblockquote %}

Que se passe-t-il exactement ? Premier élément de réponse dans la javadoc de `InvocationHandler`.

{% blockquote %}
An invocation of the hashCode, equals, or toString methods declared in java.lang.Object on a proxy instance will be encoded and dispatched to the invocation handler’s invoke method in the same manner as interface method invocations are encoded and dispatched.
{% endblockquote %}

Pas de comportement particulier pour `equals`, si bien que dans notre exemple, l’appel est simplement passé à l’objet `realAccount, avec pour argument, l’objet proxy ce qui va bien sûr renvoyer _false_.

Voilà une façon de régler le problème :

{% codeblock lang:java %}
private static class MyInvocationHandler implements InvocationHandler
{
    private UserAccount account;

    public MyInvocationHandler(UserAccount account)
    {
        this.account = account;
    }

    public Object invoke(Object proxy, Method method, Object[] args) throws Throwable
    {
        try {
            if (m.getDeclaringClass() == Object.class
                && m.getName().equals("equals")
                && args.length == 1)
            {
                Object o == args[0];
                return Proxy.isProxyClass(o) && this.equals(Proxy.getInvocationHandler(o));
            }
            method.invoke(realAccount, args);
        } finally {
            LOGGER.info(method + " called with arguments " + Arrays.toString(args));
        }
    }

    public boolean equals(Object o)
    {
        if (o == this) {
            return true;
        } else if (o == null) {
            return false;
        } else if (o instanceof MyInvocationHandler) {
            return this.account.equals(((MyInvocationHandler)o).account);
        }
        return false;
    }
}

public UserAccount wrapGood(final UserAccount realAccout)
{
    InvocationHandler handler = new MyInvocationHandler(realAccount);
    return Proxy.newProxyInstance(UserAccount.class.getClassLoader(),
        new Class[] { UserAccount.class }, handler);
}
{% endcodeblock %}

Dans cette version corrigée le cas de la méthode `equals` est gérée à part. Ensuite on considère que deux _proxies_ sont égaux s’ils utilisent la même implémentation de `InvocationHandler` et que les objets `UserAccount` encapsulés par ces _handlers_ sont égaux selon equals. Pour cela on utilise deux méthodes intéressantes de la classe `Proxy` : `isProxyClass()` qui permet de savoir si un objet est un proxy et `getInvocationHandler()` qui permet de récupérer le `InvocationHandler lié à un proxy.
