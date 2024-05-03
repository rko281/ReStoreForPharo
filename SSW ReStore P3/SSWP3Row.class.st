Class {
	#name : 'SSWP3Row',
	#superclass : 'Object',
	#traits : 'SSWReStoreDBRow',
	#classTraits : 'SSWReStoreDBRow classTrait',
	#instVars : [
		'columnNames',
		'data'
	],
	#category : 'SSW ReStore P3',
	#package : 'SSW ReStore P3'
}

{ #category : 'accessing' }
SSWP3Row >> columnNames [

	^columnNames
]

{ #category : 'accessing' }
SSWP3Row >> columns: aCollection [

	columnNames := aCollection collect: [ :each | each fieldName ]
]

{ #category : 'accessing' }
SSWP3Row >> contents [

	^data
]

{ #category : 'accessing' }
SSWP3Row >> data [
	^ data
]

{ #category : 'accessing' }
SSWP3Row >> data: anObject [
	data := anObject
]
