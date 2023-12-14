"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
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

{ #category : #evaluating }
SSWDBIntermediateTable >> subclasses [

	"Return those classes which inherit persistency from the receiver"

	^self instanceClass allSubclasses select:
		[ :each | 
		(self reStore tableForClass: each) ifNil: [false] ifNotNil: [ :table | table rootClass = self rootClass]]
]
