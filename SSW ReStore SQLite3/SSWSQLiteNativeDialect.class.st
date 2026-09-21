Class {
	#name : 'SSWSQLiteNativeDialect',
	#superclass : 'SSWSQLiteDialect',
	#traits : 'SSWSQLNativeDialect',
	#classTraits : 'SSWSQLNativeDialect classTrait',
	#category : 'SSW ReStore SQLite3',
	#package : 'SSW ReStore SQLite3'
}

{ #category : 'testing' }
SSWSQLiteNativeDialect class >> isNative [

	^true
]

{ #category : 'constants' }
SSWSQLiteNativeDialect >> defaultDateTimeResolution [

	^self maxDateTimeResolution
]
