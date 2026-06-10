Class {
	#name : 'SSWSQLiteNativeDialect',
	#superclass : 'SSWSQLiteDialect',
	#traits : 'SSWSQLNativeDialect',
	#classTraits : 'SSWSQLNativeDialect classTrait',
	#category : 'SSW ReStore SQLite3',
	#package : 'SSW ReStore SQLite3'
}

{ #category : 'constants' }
SSWSQLiteNativeDialect >> defaultDateTimeResolution [

	^self maxDateTimeResolution
]
