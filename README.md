# What is ReStore?
ReStore is a framework enabling Pharo objects to be stored in and read from relational databases (SQLite, PostgreSQL etc.). ReStore aims to make relational persistency as simple as possible, creating and maintaining the database structure itself and providing access to stored objects via familiar Smalltalk messages. 

# Getting Started 
To load ReStore into your Pharo 7 image, evaluate:

```smalltalk
Metacello new
    repository: 'github://rko281/ReStoreForPharo';
    baseline: 'ReStore';
    load
```

This will load ReStore with support for SQLite (via [UDBC](https://github.com/astares/Pharo-UDBC)) and PostgreSQL (via [P3](https://github.com/svenvc/P3)).

