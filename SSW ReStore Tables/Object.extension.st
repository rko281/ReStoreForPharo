Extension { #name : #Object }

{ #category : #'*SSW ReStore Tables' }
Object class >> addClassDefinitionTo: anSSWDBClassDefinition [

	"Add the receiver's ReStore class definition to anSSWDBClassDefinition.
	In earlier versions of ReStore classes overrode this method; this is still supported however the new standard is to override reStoreDefinition instead"

	^self
]

{ #category : #'*SSW ReStore Tables' }
Object >> convertValue: aValue [

	"Field behaviour; needed when the result of a function is a fixed value"

	^aValue
]

{ #category : #'*SSW ReStore Tables' }
Object >> dependent [

	"Return a dependent version of the receiver"

	^SSWDBDependentWrapper on: self


]

{ #category : #'*SSW ReStore Tables' }
Object class >> hasPersistentSuperclass [

	"Return whether the receiver has a superclass from which it inherits some elements of persistence"

	self shouldInheritPersistency ifFalse: [^false].

	self allSuperclasses do:
		[ :sup |
		sup = Object ifTrue: [^false].
		sup shouldSubclassesInheritPersistency ifFalse: [^false].
		sup reStoreDefinition isEmpty ifFalse: [^true]].
		
	^false
]

{ #category : #'*SSW ReStore Tables' }
Object class >> isPersistencyInherited [

	"Return whether the receiver's persistency is inherited by any subclasses"

	^self subclassesInheritingPersistency isEmpty not
]

{ #category : #'*SSW ReStore Tables' }
Object class >> persistencyRootClass [

	"Return the superclass at which the receiver's inherited persistency begins.
	ASSERT: self hasPersistentSuperclass"

	^self allSuperclasses detect: [ :sup | sup reStoreTableClass == SSWDBSuperTable]
]

{ #category : #'*SSW ReStore Tables' }
Object class >> reStoreDefinition [

	"Return anSSWDBClassDefinition setting out the details of how the receiver is to be persisted.
	Subclasses should override, adding the definition of their persistent inst vars to the result.

	In earlier versions of ReStore classes overrode addClassDefinition: to do this - this is still supported however the new standard is to override this method instead"

	| definition |

	definition := SSWDBClassDefinition forClass: self.

	self addClassDefinitionTo: definition.

	^definition
]

{ #category : #'*SSW ReStore Tables' }
Object class >> reStoreTableClass [

	"Deduce and return the correct class to use for the receiver's ReStore Table"

	^self hasPersistentSuperclass
	ifTrue: 
		[self isPersistencyInherited
			ifTrue: [SSWDBIntermediateTable]
			ifFalse: [SSWDBSubTable]]
	ifFalse:
		[self isPersistencyInherited
			ifTrue: [SSWDBSuperTable]
			ifFalse: [SSWDBTable]]
]

{ #category : #'*SSW ReStore Tables' }
Object >> related [

	"Return a related version of the receiver"

	^SSWDBRelatedWrapper on: self


]

{ #category : #'*SSW ReStore Tables' }
Object class >> shouldInheritPersistency [

	"Return a Boolean indicating whether the receiver should inherit persistence
	information defined by its superclasses.
	
	By default, this is governed by the superclass implementation of shouldSubclassesInheritPersistence"

	^self superclass ~= nil and: [self superclass shouldSubclassesInheritPersistency]
]

{ #category : #'*SSW ReStore Tables' }
Object class >> shouldInlinePersistency [

	"Return whether this class should always be inlined when referenced from another class's reStoreDefinition"

	^false
]

{ #category : #'*SSW ReStore Tables' }
Object class >> shouldSubclassesInheritPersistency [

	"Return a Boolean indicating whether the receiver class' persistency 
	should be inherited by its subclasses.
	
	Default - true. Can be overriden if required.
	NB persistency-inheriting subclasses can implement shouldInheritPersistency
	to prevent (only) persistency inheritence if this method returns true"

	^true
]

{ #category : #'*SSW ReStore Tables' }
Object class >> subclassesInheritingPersistency [

	"Return a collection of those subclasses of the receiver class
	which are persistent and inherit the receiver's peristency - i.e. share a table"

	| inheritingPersistentSubclasses |

	self shouldSubclassesInheritPersistency ifFalse: [^#()].
	
	inheritingPersistentSubclasses := 
		(self subclasses select: [ :cls | cls isMeta not and: [cls shouldInheritPersistency]]) asOrderedCollection.
	
	inheritingPersistentSubclasses copy do: 
		[ :cls | 
		inheritingPersistentSubclasses addAll: cls subclassesInheritingPersistency].
	
	^inheritingPersistentSubclasses
]

{ #category : #'*SSW ReStore Tables' }
Object class >> tableIn: anSSWReStore [

	"Private - Create and return an SSWDB(XXX)Table to represent the receiver.
	Subclasses should *NOT* override this method;
	instead implement reStoreDefinition"

	^self reStoreDefinition asTableIn: anSSWReStore
]

{ #category : #'*SSW ReStore Tables' }
Object >> targetClass [

	"Required when a static value (e.g. String, Number) is used in place of a field (e.g. in a SQL function)"

	^self class
]

{ #category : #'*SSW ReStore Tables' }
Object >> unrelated [

	"Return an unrelated version of the receiver"

	^SSWDBUnrelatedWrapper on: self
]
