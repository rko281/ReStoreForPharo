"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : 'SSWTransformingInstVarAccessor',
	#superclass : 'SSWInstVarAccessor',
	#instVars : [
		'transformation'
	],
	#category : 'SSW ReStore Tables',
	#package : 'SSW ReStore Tables'
}

{ #category : 'instance creation' }
SSWTransformingInstVarAccessor class >> newWithTransformation: aMonadicValuable [

	^self new
		transformation: aMonadicValuable;
		yourself
]

{ #category : 'accessing' }
SSWTransformingInstVarAccessor >> transformation [

	"transformation stores a monadic valuable (zero-arg Message or 1-arg block)
	which transforms the actual object held in the inst var accessed by the receiver to another object"

	^transformation
]

{ #category : 'accessing' }
SSWTransformingInstVarAccessor >> transformation: aMonadicValuable [

	"transformation stores a monadic valuable (zero-arg Message or 1-arg block)
	which transforms the actual object held in the inst var accessed by the receiver to another object"

	transformation := aMonadicValuable
]

{ #category : 'evaluating' }
SSWTransformingInstVarAccessor >> valueIn: anObject [

	"Override to apply the transformation.
	Also update anObject so it is storing the transformed value"	

	| origValue modValue |

	origValue := super valueIn: anObject.
	modValue := self transformation value: origValue.

	origValue ~~ modValue ifTrue: [self value: modValue in: anObject].

	^modValue
]
