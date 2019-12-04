Class {
	#name : #SSWP3Row,
	#superclass : #Object,
	#instVars : [
		'columns',
		'data',
		'fieldMap'
	],
	#category : #'SSW ReStore P3'
}

{ #category : #accessing }
SSWP3Row >> atField: aField [

	^self atField: aField ifAbsent: [nil]

]

{ #category : #accessing }
SSWP3Row >> atField: aField ifAbsent: aBlock [

	^fieldMap at: aField ifAbsent: aBlock
]

{ #category : #accessing }
SSWP3Row >> atIndex: anInteger [

	^data at: anInteger
]

{ #category : #accessing }
SSWP3Row >> columns [
	^ columns
]

{ #category : #accessing }
SSWP3Row >> columns: anObject [
	columns := anObject
]

{ #category : #accessing }
SSWP3Row >> createFieldMapFrom: aDBQuery [

	fieldMap := Dictionary new.
	columns with: data do: 
		[ :column :value | 
		fieldMap at: (aDBQuery fieldNamed: column fieldName) put: value ]
]

{ #category : #accessing }
SSWP3Row >> data [
	^ data
]

{ #category : #accessing }
SSWP3Row >> data: anObject [
	data := anObject
]

{ #category : #accessing }
SSWP3Row >> fieldMap [
	^ fieldMap
]

{ #category : #accessing }
SSWP3Row >> fieldMap: anObject [
	fieldMap := anObject
]
