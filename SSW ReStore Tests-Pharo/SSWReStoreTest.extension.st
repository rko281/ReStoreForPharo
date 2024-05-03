Extension { #name : #SSWReStoreTest }

{ #category : #'*SSW ReStore Tests-Pharo' }
SSWReStoreTest >> addMethod: aCompiledMethod withSelector: aSymbol toClass: aClass [

	"Add/replace the method named aSymbol in aClass with aCompiledMethod.
	This is a temporary addition/replacement for the purposes of a test case; do not update aCompiledMethod"
	aClass methodDictionary at: aSymbol put: aCompiledMethod
]

{ #category : #'*SSW ReStore Tests-Pharo' }
SSWReStoreTest >> debugStream [

	^nil
]

{ #category : #'*SSW ReStore Tests-Pharo' }
SSWReStoreTest >> errorPrefix [

	^'Error: '
]

{ #category : #'*SSW ReStore Tests-Pharo' }
SSWReStoreTest >> initConnectionFor: aReStore [

	"Use SQLite in memory"
	aReStore connection: (SSWSQLite3Connection on: 'file::memory:?cache=shared')
	
	"Templates for other connectors:
	aReStore connection: (SSWODBCConnection new dsn: 'YourDSN')
	aReStore connection: (SSWODBCConnection new connectString: 'DRIVER={};etc.')
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
SSWReStoreTest >> removeSelector: aSymbol fromClass: aClass [

	aClass methodDictionary removeKey: aSymbol
]

{ #category : #'*SSW ReStore Tests-Pharo' }
SSWReStoreTest >> should: aBlock raise: anErrorClass matching: errorBlock [

	self assert: ([aBlock value. false] on: anErrorClass do: [  :exc | exc return: (errorBlock value: exc) ])
]

{ #category : #'*SSW ReStore Tests-Pharo' }
SSWReStoreTest class >> shouldInheritSelectors [ 

	^true
]
