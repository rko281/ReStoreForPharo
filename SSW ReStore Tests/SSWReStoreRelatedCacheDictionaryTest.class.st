"
ReStore
¬©2020 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SSWReStoreRelatedCacheDictionaryTest,
	#superclass : #SSWReStoreRelatedDictionaryTest,
	#category : #'SSW ReStore Tests'
}

{ #category : #accessing }
SSWReStoreRelatedCacheDictionaryTest class >> allTestSelectors [

	^super allTestSelectors 
		removeAll: self multipleOccurrenceTestSelectors;
		yourself
]

{ #category : #helpers }
SSWReStoreRelatedCacheDictionaryTest >> addToCollection: aCollection [

	| component |

	component := self templateComponent.

	^aCollection at: component key put: component
]

{ #category : #accessing }
SSWReStoreRelatedCacheDictionaryTest >> componentDefinition [

	^(Dictionary of: #key -> GenericOwnedTest related)
]

{ #category : #helpers }
SSWReStoreRelatedCacheDictionaryTest >> remove: anObject fromCollection: aCollection [

	^aCollection removeKey: anObject key
]

{ #category : #public }
SSWReStoreRelatedCacheDictionaryTest >> replaceInCollection: aCollection [

	| key old |

	key := aCollection keys anyOne.
	old := aCollection at: key.
	^old -> (aCollection at: key put: (self templateComponent key: key; yourself))
]

{ #category : #accessing }
SSWReStoreRelatedCacheDictionaryTest >> templateCollection [

	| templateCollection |

	templateCollection := Dictionary new.

	5 timesRepeat: 
		[| component |
		component := self templateComponent.
		templateCollection at: component key put: component].

	^templateCollection
]

{ #category : #public }
SSWReStoreRelatedCacheDictionaryTest >> templateComponent [

	| component |

	component := super templateComponent.

	component key: component name.

	^component
]
