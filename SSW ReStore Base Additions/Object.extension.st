Extension { #name : #Object }

{ #category : #'*SSW ReStore Base Additions' }
Object >> _instVarAt: anInteger put: anObject [

	"Make the receiver polymorphic with proxies"
	
	^self instVarAt: anInteger put: anObject
]

{ #category : #'*SSW ReStore Base Additions' }
Object >> chainPerform: aCollection [

	"perform: each member (Symbol) of aCollection against the receiver as a chain
	i.e. the second Symbol is perform:'d against the result of perform:ing the first, etc."

	^aCollection inject: self into: [ :receiver :symbol | receiver perform: symbol]

]

{ #category : #'*SSW ReStore Base Additions' }
Object >> includedIn: aCollection [

	"Reciprocal of Collection>>includes: "

	^aCollection includes: self
]

{ #category : #'*SSW ReStore Base Additions' }
Object class >> isPersistentBaseClass [

	"Return whether the receiver class is a valid persistent base class
	 - a class which can be represented in the DB by a single field type, rather than a table.

	false by default, subclasses which are so valid may override"

	^false
]
