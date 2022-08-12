"
ReStore
©2020 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWInlinedInstVarAccessor,
	#superclass : #SSWInstVarAccessor,
	#instVars : [
		'inlinedAccessor',
		'inlinedClass'
	],
	#category : #'SSW ReStore Tables'
}

{ #category : #testing }
SSWInlinedInstVarAccessor >> accesses: aSymbol [

	"Test whether the receiver itself directly (shallowly) accesses aSymbol.
	The inlinedAccessor's access path is not considered"

	^self accessesShallowly: aSymbol
]

{ #category : #testing }
SSWInlinedInstVarAccessor >> accessesDeeply: aSymbol [

	"Return whether the receiver accesses an inst var named aSymbol at a level deeper than that tested for by #accesses:"

	^(self inlinedAccessor accesses: aSymbol) or: [self inlinedAccessor accessesDeeply: aSymbol]
]

{ #category : #testing }
SSWInlinedInstVarAccessor >> accessesShallowly: aSymbol [

	"Return whether the receiver shallowly/immediately accesses an inst var named aSymbol.
	This is the type of access provided by the superclass"

	^super accesses: aSymbol
]

{ #category : #updating }
SSWInlinedInstVarAccessor >> copyValue: valueObject in: targetObject [

	^self inlinedAccessor copyValue: valueObject in: (self inlinedValueIn: targetObject)
]

{ #category : #evaluating }
SSWInlinedInstVarAccessor >> copyValueIn: sourceObject to: targetObject [

	"targetObject is a shallow copy of sourceObject; perform any additional copying necessary.
	The receiver needs to copy the inlined object if this hasn't already been done (i.e. by another inlined accessor on the same inst var), and pass on to its inlinedAccessor"

	| sourceValue targetValue |

	sourceValue := self shallowValueIn: sourceObject.
	sourceValue isNil ifTrue: [^self].

	targetValue := self shallowValueIn: targetObject.

	sourceValue == targetValue ifTrue: 
		[targetValue := sourceValue shallowCopy.
		self shallowValue: targetValue in: targetObject].

	self inlinedAccessor copyValueIn: sourceValue to: targetValue
]

{ #category : #accessing }
SSWInlinedInstVarAccessor >> inlinedAccessor [
	^inlinedAccessor
]

{ #category : #accessing }
SSWInlinedInstVarAccessor >> inlinedAccessor: anObject [
	inlinedAccessor := anObject
]

{ #category : #accessing }
SSWInlinedInstVarAccessor >> inlinedClass [
	^inlinedClass
]

{ #category : #accessing }
SSWInlinedInstVarAccessor >> inlinedClass: anObject [
	inlinedClass := anObject
]

{ #category : #accessing }
SSWInlinedInstVarAccessor >> inlinedClassDeeply [

	^self inlinedAccessor isInlined
		ifTrue: [self inlinedAccessor inlinedClassDeeply]
		ifFalse: [self inlinedClass]
]

{ #category : #updating }
SSWInlinedInstVarAccessor >> inlinedValueIn: targetObject [

	"Private - Return the inlined object in targetObject, creating and assigning it if necessary"

	^(self shallowValueIn: targetObject) ifNil: [self shallowValue: self inlinedClass new in: targetObject]
]

{ #category : #testing }
SSWInlinedInstVarAccessor >> isInlined [

	^true
]

{ #category : #updating }
SSWInlinedInstVarAccessor >> shallowValue: valueObject in: targetObject [

	^super value: valueObject in: targetObject
]

{ #category : #updating }
SSWInlinedInstVarAccessor >> shallowValueIn: targetObject [

	^super valueIn: targetObject
]

{ #category : #updating }
SSWInlinedInstVarAccessor >> value: valueObject in: targetObject [

	^self inlinedAccessor value: valueObject in: (self inlinedValueIn: targetObject)
]

{ #category : #updating }
SSWInlinedInstVarAccessor >> valueIn: targetObject [

	| inlined |

	inlined := self shallowValueIn: targetObject.

	^inlined isNil 
		ifTrue: [nil]
		ifFalse: [self inlinedAccessor valueIn: inlined]
]
