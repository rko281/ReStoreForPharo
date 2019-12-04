"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWDBIntermediateTable,
	#superclass : #SSWDBAbstractSubTable,
	#category : #'SSW ReStore Tables'
}

{ #category : #evaluating }
SSWDBIntermediateTable >> _classCondition [

	"For an intermediate table we have to consider subclasses"

	| conditions |

	conditions := SSWSQLConditionCollection forOR.

	conditions add: super _classCondition.
	self subclasses do: [ :each | conditions add: (SSWSQLCondition field: self classField equalTo: each)].

	^conditions
]

{ #category : #'instance creation' }
SSWDBIntermediateTable >> recoverInstanceFromRow: aDBRow into: anSSWDBObjectProxy [
	
	"Redirect to the relevant concrete class. Also set the class of the proxy to the actual class of object.
	(since this may be one of the receiver's instanceClass' subclasses)"
	
	| class |
	
	class := self instanceClassFromRow: aDBRow.

	class = self instanceClass
		ifTrue: [super recoverInstanceFromRow: aDBRow into: anSSWDBObjectProxy]
		ifFalse: [(self reStore tableForClass: class) 
				recoverInstanceFromRow: aDBRow into: anSSWDBObjectProxy].
	
	anSSWDBObjectProxy _class: anSSWDBObjectProxy _proxiedObject class
]

{ #category : #evaluating }
SSWDBIntermediateTable >> subclasses [

	"Return those classes which inherit persistency from the receiver"

	^self instanceClass allSubclasses select:
		[ :each | 
		(self reStore tableForClass: each) ifNil: [false] ifNotNil: [ :table | table rootClass = self rootClass]]
]
