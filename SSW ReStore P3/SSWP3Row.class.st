Class {
	#name : #SSWP3Row,
	#superclass : #Object,
	#traits : 'SSWReStoreDBRow',
	#classTraits : 'SSWReStoreDBRow classTrait',
	#instVars : [
		'columns',
		'data',
		'fieldMap'
	],
	#category : #'SSW ReStore P3'
}

{ #category : #accessing }
SSWP3Row >> columns [
	^ columns
]

{ #category : #accessing }
SSWP3Row >> columns: anObject [
	columns := anObject
]

{ #category : #accessing }
SSWP3Row >> data [
	^ data
]

{ #category : #accessing }
SSWP3Row >> data: anObject [
	data := anObject
]
