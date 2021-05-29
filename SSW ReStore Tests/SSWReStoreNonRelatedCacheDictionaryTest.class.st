"
ReStore
¬©2020 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SSWReStoreNonRelatedCacheDictionaryTest,
	#superclass : #SSWReStoreNonRelatedDictionaryTest,
	#category : #'SSW ReStore Tests'
}

{ #category : #accessing }
SSWReStoreNonRelatedCacheDictionaryTest class >> allTestSelectors [

	^super allTestSelectors 
		removeAll: self multipleOccurrenceTestSelectors;
		yourself
]

{ #category : #helpers }
SSWReStoreNonRelatedCacheDictionaryTest >> addToCollection: aCollection [

	| component |

	component := self templateComponent.

	^aCollection at: component key put: component
]

{ #category : #accessing }
SSWReStoreNonRelatedCacheDictionaryTest >> componentDefinition [

	^(Dictionary of: #key -> GenericOwnedTest)
]

{ #category : #helpers }
SSWReStoreNonRelatedCacheDictionaryTest >> remove: anObject fromCollection: aCollection [

	^aCollection removeKey: anObject key
]

{ #category : #public }
SSWReStoreNonRelatedCacheDictionaryTest >> replaceInCollection: aCollection [

	| key old |

	key := aCollection keys anyOne.
	old := aCollection at: key.
	^old -> (aCollection at: key put: (self templateComponent key: key; yourself))
]

{ #category : #accessing }
SSWReStoreNonRelatedCacheDictionaryTest >> templateCollection [

	| templateCollection |

	templateCollection := Dictionary new.

	5 timesRepeat: 
		[| component |
		component := self templateComponent.
		templateCollection at: component key put: component].

	^templateCollection
]

{ #category : #public }
SSWReStoreNonRelatedCacheDictionaryTest >> templateComponent [

	| component |

	component := super templateComponent.

	component key: component name.

	^component
]
