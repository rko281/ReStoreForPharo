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

	aReStore connection: (SSWP3Connection new url: 'psql://testclient:abcd@192.168.1.104:5432/test')
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
