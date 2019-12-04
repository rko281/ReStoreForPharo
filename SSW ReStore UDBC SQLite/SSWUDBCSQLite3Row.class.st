Class {
	#name : #SSWUDBCSQLite3Row,
	#superclass : #UDBCSQLite3Row,
	#instVars : [
		'fieldMap'
	],
	#category : #'SSW ReStore UDBC SQLite'
}

{ #category : #accessing }
SSWUDBCSQLite3Row >> atField: aField [

	^self atField: aField ifAbsent: [nil]

]

{ #category : #accessing }
SSWUDBCSQLite3Row >> atField: aField ifAbsent: aBlock [

	^fieldMap at: aField ifAbsent: aBlock
]

{ #category : #'as yet unclassified' }
SSWUDBCSQLite3Row >> createFieldMapFrom: aDBQuery [

	fieldMap := Dictionary new.
	data keysAndValuesDo: 
		[ :key :value |
		key isString ifTrue: [ fieldMap at: (aDBQuery fieldNamed: key) put: value ] ]
]

{ #category : #accessing }
SSWUDBCSQLite3Row >> fieldMap [
	^ fieldMap
]
