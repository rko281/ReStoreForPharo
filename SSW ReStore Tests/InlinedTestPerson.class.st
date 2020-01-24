"
ReStore
©2020 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #InlinedTestPerson,
	#superclass : #Object,
	#instVars : [
		'firstName',
		'surname',
		'address1',
		'address2',
		'address3',
		'line1',
		'code1',
		'bankBalance'
	],
	#category : #'SSW ReStore Tests'
}

{ #category : #public }
InlinedTestPerson class >> reStoreDefinition [

	^super reStoreDefinition
		define: #firstName as: (String maxSize: 64);
		define: #surname as: (String maxSize: 96);
		define: #address1 as: InlinedAddress inlined;
		define: #address2 as: InlinedAddress inlined;
		define: #address3 as: SimpleAddress;
		define: #line1 as: (String maxSize: 64);
		define: #code1 as: (String maxSize: 64);
		define: #bankBalance as: NumberWithCurrency "<- always inlined"
]

{ #category : #accessing }
InlinedTestPerson >> address1 [
	^address1
]

{ #category : #accessing }
InlinedTestPerson >> address1: anObject [
	address1 := anObject
]

{ #category : #accessing }
InlinedTestPerson >> address2 [
	^address2
]

{ #category : #accessing }
InlinedTestPerson >> address2: anObject [
	address2 := anObject
]

{ #category : #accessing }
InlinedTestPerson >> address3 [
	^address3
]

{ #category : #accessing }
InlinedTestPerson >> address3: anObject [
	address3 := anObject
]

{ #category : #accessing }
InlinedTestPerson >> bankBalance [
	^bankBalance
]

{ #category : #accessing }
InlinedTestPerson >> bankBalance: anObject [
	bankBalance := anObject
]

{ #category : #accessing }
InlinedTestPerson >> bankBalanceString [
	^bankBalance displayString
]

{ #category : #accessing }
InlinedTestPerson >> code1 [
	^code1
]

{ #category : #accessing }
InlinedTestPerson >> code1: anObject [
	code1 := anObject
]

{ #category : #accessing }
InlinedTestPerson >> firstName [
	^firstName
]

{ #category : #accessing }
InlinedTestPerson >> firstName: anObject [
	firstName := anObject
]

{ #category : #accessing }
InlinedTestPerson >> line1 [
	^line1
]

{ #category : #accessing }
InlinedTestPerson >> line1: anObject [
	line1 := anObject
]

{ #category : #accessing }
InlinedTestPerson >> surname [
	^surname
]

{ #category : #accessing }
InlinedTestPerson >> surname: anObject [
	surname := anObject
]
