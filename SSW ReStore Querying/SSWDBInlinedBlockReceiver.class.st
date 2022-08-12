"
ReStore
©2020 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWDBInlinedBlockReceiver,
	#superclass : #SSWDBBlockArgument,
	#instVars : [
		'inlinedInstVar',
		'inlinedFields'
	],
	#category : #'SSW ReStore Querying'
}

{ #category : #parsing }
SSWDBInlinedBlockReceiver >> _doesNotUnderstand: aMessage [

	| result matchingFields |

	^aMessage argumentCount > 0 
	ifTrue: 
		[(aMessage selector last = $: and: [aMessage arguments size = 1])
		ifTrue:
			[self inlinedFields: (self inlinedFieldsAccessing: aMessage selector allButLast asSymbol).
			self hasFinalField
				ifTrue: [self sqlConditionFor: aMessage]
				ifFalse: [self parseError: 'unknown/ambiguous update']]
		ifFalse: 
			[self hasFinalField 
			ifTrue: 
				[result := super _doesNotUnderstand: aMessage. 
				self reset.
				result] 
			ifFalse: 
				[self simulateMessageSend: aMessage]]]
	ifFalse:
		[matchingFields := self inlinedFieldsAccessing: aMessage selector.
		matchingFields isEmpty
		ifTrue: 
			[super _doesNotUnderstand: aMessage]
		ifFalse: 
			[self inlinedFields: matchingFields.
			self]]
]

{ #category : #accessing }
SSWDBInlinedBlockReceiver >> currentClass [

	^self inlinedFields first accessor inlinedClassDeeply
]

{ #category : #accessing }
SSWDBInlinedBlockReceiver >> finalField [

	^self hasFinalField
		ifTrue: [self inlinedFields first]
		ifFalse: [self parseError: 'Parse error in inlined table']
]

{ #category : #testing }
SSWDBInlinedBlockReceiver >> hasFinalField [

	^self inlinedFields size = 1
]

{ #category : #accessing }
SSWDBInlinedBlockReceiver >> inlinedFields [

	^inlinedFields ifNil: [inlinedFields := (self parser tableForClass: self rootClass) fieldsAccessing: self inlinedInstVar]

]

{ #category : #accessing }
SSWDBInlinedBlockReceiver >> inlinedFields: anObject [
	inlinedFields := anObject
]

{ #category : #parsing }
SSWDBInlinedBlockReceiver >> inlinedFieldsAccessing: aSymbol [

	^self inlinedFields select: [ :each | each accessor accessesDeeply: aSymbol]
]

{ #category : #accessing }
SSWDBInlinedBlockReceiver >> inlinedInstVar [
	^inlinedInstVar
]

{ #category : #accessing }
SSWDBInlinedBlockReceiver >> inlinedInstVar: anObject [
	inlinedInstVar := anObject
]

{ #category : #accessing }
SSWDBInlinedBlockReceiver >> peekFinalField [

	^self hasFinalField
		ifTrue: [self inlinedFields first]
		ifFalse: [nil]
]

{ #category : #parsing }
SSWDBInlinedBlockReceiver >> reset [

	self inlinedFields: nil
]

{ #category : #accessing }
SSWDBInlinedBlockReceiver >> rootClass [

	^super currentClass
]
