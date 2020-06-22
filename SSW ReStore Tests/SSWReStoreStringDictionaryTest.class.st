Class {
	#name : #SSWReStoreStringDictionaryTest,
	#superclass : #SSWReStoreGenericTest,
	#category : #'SSW ReStore Tests'
}

{ #category : #accessing }
SSWReStoreStringDictionaryTest >> componentDefinition [

	^Dictionary of: (String maxSize: 50) -> (String maxSize: 50)
]

{ #category : #accessing }
SSWReStoreStringDictionaryTest >> templateTestObject [

	| template |

	template := GenericTest new.
	template component: Dictionary new.

	1 to: 5 do: [ :index | template component at: ('key', index displayString) put: ('value', index displayString)].

	^template
	
]

{ #category : #'unit tests' }
SSWReStoreStringDictionaryTest >> testTemplateObject [

	self assert: testObject component size = 5.

	1 to: 5 do: 
		[ :index |
		self assert: (testObject component at: ('key', index displayString)) equals: ('value', index displayString)]
]
