"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SSWInstVarAccessor,
	#superclass : #SSWAccessor,
	#instVars : [
		'ownerClass',
		'slot',
		'name'
	],
	#category : #'SSW ReStore Tables'
}

{ #category : #'instance creation' }
SSWInstVarAccessor class >> toAccess: anInstVarName in: aClass [

	^self new
		access: anInstVarName in: aClass;
		yourself
]

{ #category : #testing }
SSWInstVarAccessor >> = anSSWAccessor [

	^(self ownerClass = anSSWAccessor ownerClass) and: [self slot = anSSWAccessor slot]
]

{ #category : #initializing }
SSWInstVarAccessor >> access: aSymbol in: aClass [

	"Configure the receiver to access the inst var of aClass which is named aSymbol"
	
	| instVarName instVarSlot |

	"Veirfy a valid inst var slot"
	instVarName := aSymbol asInstVarName. "in case aSymbol is something else (e.g. SSWDBInstVarWithFieldName)"
	instVarSlot := aClass allInstVarNames indexOf: instVarName asString.
	instVarSlot < 1 ifTrue: [self error: ('Undefined instance variable ', aSymbol)].

	self 
		ownerClass: aClass;
		slot: instVarSlot;
		name: instVarName
]

{ #category : #testing }
SSWInstVarAccessor >> accesses: aSymbol [

	^self name = aSymbol
]

{ #category : #testing }
SSWInstVarAccessor >> accessesDeeply: aSymbol [

	^false
]

{ #category : #updating }
SSWInstVarAccessor >> copyValue: valueObject in: targetObject [

	"Set the instance variable of targetObject represented by the receiver to valueObject.
	Compared to value:in: the implication here is that valueObject may need copying to make an independent object.

	Default action - copying is not needed"

	^self value: valueObject in: targetObject
]

{ #category : #evaluating }
SSWInstVarAccessor >> copyValueIn: sourceObject to: targetObject [

	"targetObject is a shallow copy of sourceObject.Perform any additional copying necessary.
	A no-op by default"

	^self
]

{ #category : #testing }
SSWInstVarAccessor >> hash [

	^self ownerClass hash + self slot hash
]

{ #category : #accessing }
SSWInstVarAccessor >> name [

	"name stores the name of the instance variable accessed by the receiver,
	as a Symbol"
	
	^name
]

{ #category : #accessing }
SSWInstVarAccessor >> name: aSymbol [

	"name stores the name of the instance variable accessed by the receiver,
	as a Symbol"
	
	name := aSymbol
]

{ #category : #accessing }
SSWInstVarAccessor >> ownerClass [

	"ownerClass stores the class whose instance variable is accessed by the receiver"
	
	^ownerClass
]

{ #category : #accessing }
SSWInstVarAccessor >> ownerClass: aClass [

	"ownerClass stores the class whose instance variable is accessed by the receiver"
	
	ownerClass := aClass
]

{ #category : #accessing }
SSWInstVarAccessor >> slot [

	"slot stores the index of the instance variable accessed by the receiver"
	
	^slot
]

{ #category : #accessing }
SSWInstVarAccessor >> slot: anInteger [

	"slot stores the index of the instance variable accessed by the receiver"
	
	slot := anInteger
]

{ #category : #evaluating }
SSWInstVarAccessor >> value: targetObject [

	"Polymorphic with Blocks and Messages"

	^targetObject perform: self name
]

{ #category : #updating }
SSWInstVarAccessor >> value: valueObject in: targetObject [

	"Set the instance variable of targetObject represented by the receiver to valueObject"

	^targetObject _instVarAt: self slot put: valueObject
]

{ #category : #evaluating }
SSWInstVarAccessor >> valueIn: targetObject [

	"Return the value of the instance variable of targetObject represented by the receiver"

	^targetObject _instVarAt: self slot
]
