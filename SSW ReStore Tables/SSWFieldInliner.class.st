"
ReStore
©2020 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : 'SSWFieldInliner',
	#superclass : 'Object',
	#instVars : [
		'table',
		'instanceClass',
		'inlinedName',
		'inlinedSlot',
		'inlinedClass',
		'fields'
	],
	#category : 'SSW ReStore Tables',
	#package : 'SSW ReStore Tables'
}

{ #category : 'instance creation' }
SSWFieldInliner class >> new [

	^super new
		fields: OrderedCollection new;
		yourself
]

{ #category : 'defining' }
SSWFieldInliner >> define: aSymbol as: anObject [

	"Double-despatch; the object knows how to define itself"
	^anObject defineAs: aSymbol in: self
]

{ #category : 'defining' }
SSWFieldInliner >> define: aSymbol asInstVarHolding: anObject [

	| rootTable cachedInstanceClass field |

	rootTable := self rootTable.
	cachedInstanceClass := rootTable instanceClass.
	[rootTable instanceClass: self inlinedClass.
	field := rootTable define: aSymbol asInstVarHolding: anObject] ensure: [rootTable instanceClass: cachedInstanceClass].

	self wrapField: field.

	^self fields add: field
]

{ #category : 'defining' }
SSWFieldInliner >> define: aSymbol asInstVarHoldingInlined: aClass [

	| inliner |

	inliner := SSWFieldInliner new.
	inliner 
		table: self;
		instanceClass: self inlinedClass;
		inlinedName: aSymbol;
		inlinedSlot: (self inlinedClass allInstVarNames indexOf: aSymbol asString);
		inlinedClass: aClass .

	inliner inlinedSlot < 1 ifTrue: [self error: ('Undefined instance variable ', aSymbol)].

	aClass reStoreDefinition addDefinitionToTable: inliner.

	inliner fields do: [ :each | self wrapField: each]
]

{ #category : 'accessing' }
SSWFieldInliner >> fields [
	^fields
]

{ #category : 'accessing' }
SSWFieldInliner >> fields: anObject [
	fields := anObject
]

{ #category : 'accessing' }
SSWFieldInliner >> inlinedClass [
	^inlinedClass
]

{ #category : 'accessing' }
SSWFieldInliner >> inlinedClass: anObject [
	inlinedClass := anObject
]

{ #category : 'accessing' }
SSWFieldInliner >> inlinedName [
	^inlinedName
]

{ #category : 'accessing' }
SSWFieldInliner >> inlinedName: anObject [
	inlinedName := anObject
]

{ #category : 'accessing' }
SSWFieldInliner >> inlinedSlot [
	^inlinedSlot
]

{ #category : 'accessing' }
SSWFieldInliner >> inlinedSlot: anObject [
	inlinedSlot := anObject
]

{ #category : 'accessing' }
SSWFieldInliner >> instanceClass [
	^instanceClass
]

{ #category : 'accessing' }
SSWFieldInliner >> instanceClass: anObject [
	instanceClass := anObject
]

{ #category : 'accessing' }
SSWFieldInliner >> rootTable [

	^self table rootTable
]

{ #category : 'accessing' }
SSWFieldInliner >> table [
	^table
]

{ #category : 'accessing' }
SSWFieldInliner >> table: anObject [
	table := anObject
]

{ #category : 'defining' }
SSWFieldInliner >> wrapField: aField [

	| prefix |

	prefix := self rootTable sqlDialect transformInstVarName: (self inlinedName, '_') asSymbol.
	aField name: (prefix, aField name).

	aField accessor: 
		((SSWInlinedInstVarAccessor toAccess: self inlinedName in: self instanceClass)
			inlinedClass: self inlinedClass;
			inlinedAccessor: aField accessor;
			yourself)
]
