"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
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
	
	| instVarSlot |

	"Veirfy a valid inst var slot"
	instVarSlot := aClass allInstVarNames indexOf: aSymbol asString.
	instVarSlot < 1 ifTrue: [self error: ('Undefined instance variable ', aSymbol)].

	self 
		ownerClass: aClass;
		slot: instVarSlot;
		name: aSymbol
]

{ #category : #testing }
SSWInstVarAccessor >> accesses: aSymbol [

	^self name = aSymbol
]

{ #category : #testing }
SSWInstVarAccessor >> accessesDeeply: aSymbol [

	^false
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

	^self valueIn: targetObject
]

{ #category : #updating }
SSWInstVarAccessor >> value: valueObject in: targetObject [

	"Set the instance variable of targetObject represented by the receiver to valueObject"

	targetObject _instVarAt: self slot put: valueObject
]

{ #category : #evaluating }
SSWInstVarAccessor >> valueIn: targetObject [

	"Return the value of the instance variable of targetObject represented by the receiver"

	^targetObject instVarAt: self slot
]
