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
