Class {
	#name : 'SSWMySQLNativeDialect',
	#superclass : 'SSWMySQLDialect',
	#traits : 'SSWSQLNativeDialect',
	#classTraits : 'SSWSQLNativeDialect classTrait',
	#category : 'SSW ReStore MySQL',
	#package : 'SSW ReStore MySQL'
}

{ #category : 'constants' }
SSWMySQLNativeDialect >> postLoginScript [

	"All communication to/from the client is in UTF8"

	^'SET NAMES utf8mb4 '
]
