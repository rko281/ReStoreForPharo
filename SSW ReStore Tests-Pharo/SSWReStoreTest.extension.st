Extension { #name : #SSWReStoreTest }

{ #category : #'*SSW ReStore Tests-Pharo' }
SSWReStoreTest >> countQueries [

	self resetQueryCount.
]

{ #category : #'*SSW ReStore Tests-Pharo' }
SSWReStoreTest >> debugStream [

	^nil
]

{ #category : #'*SSW ReStore Tests-Pharo' }
SSWReStoreTest >> initConnectionFor: aReStore [

	"Use SQLite in memory"
	aReStore connection: (SSWSQLite3Connection on: 'file::memory:?cache=shared')
	
	"Templates for other connectors:
	aReStore connection: (SSWP3Connection new url: 'psql://user:pwd@192.168.1.234:5432/database')
	aReStore connection: (SSWMySQLConnection new connectionSpec: (MySQLDriverSpec new db: 'database'; host: '192.168.1.234'; port: 3306; user: 'user'; password: 'pwd'; yourself); yourself)"
]

{ #category : #'*SSW ReStore Tests-Pharo' }
SSWReStoreTest >> isDolphin [

	^false
]

{ #category : #'*SSW ReStore Tests-Pharo' }
SSWReStoreTest class >> listModelClass [

	"Not in Pharo"
	
	^OrderedCollection
]

{ #category : #'*SSW ReStore Tests-Pharo' }
SSWReStoreTest class >> listModelOn: aCollection [

	"Not in Pharo"
	
	^aCollection
]

{ #category : #'*SSW ReStore Tests-Pharo' }
SSWReStoreTest >> queryCount [

	^reStore connection queryCount
]

{ #category : #'*SSW ReStore Tests-Pharo' }
SSWReStoreTest >> resetQueryCount [

	^reStore connection resetQueryCount
]

{ #category : #'*SSW ReStore Tests-Pharo' }
SSWReStoreTest >> stopQueryCounting [

	reStore connection stopQueryCounting
]
