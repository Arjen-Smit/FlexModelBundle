<?xml version='1.0' encoding='UTF-8'?>
<xsl:stylesheet version='1.0' xmlns:xsl='http://www.w3.org/1999/XSL/Transform'>
    <!--
    This XSL stylesheet transforms the FlexModel XML into Doctrine mapping XML.
    -->

    <!--
    Output XML.
    -->
    <xsl:output method='xml' version='1.0' encoding='UTF-8' indent='yes'/>

    <!--
    Add the Doctrine mapping root node.
    -->
    <xsl:template match='/flexmodel'>
        <doctrine-mapping xmlns='http://doctrine-project.org/schemas/orm/doctrine-mapping'
                          xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'
                          xsi:schemaLocation='http://doctrine-project.org/schemas/orm/doctrine-mapping http://raw.github.com/doctrine/doctrine2/master/doctrine-mapping.xsd'>

            <xsl:comment>This file is generated by FlexModel. Update the FlexModel configuration and regenerate this file.</xsl:comment>

            <xsl:apply-templates select='object[@name = $objectName]'/>
        </doctrine-mapping>
    </xsl:template>

    <!--
    Add an entity.
    -->
    <xsl:template match='object'>
        <xsl:element name='entity' namespace='http://doctrine-project.org/schemas/orm/doctrine-mapping'>
            <xsl:attribute name='name'><xsl:value-of select='$objectNamespace'/><xsl:value-of select='@name'/></xsl:attribute>
            <xsl:element name='id' namespace='http://doctrine-project.org/schemas/orm/doctrine-mapping'>
                <xsl:attribute name='name'>id</xsl:attribute>
                <xsl:attribute name='type'>integer</xsl:attribute>

                <xsl:element name='generator' namespace='http://doctrine-project.org/schemas/orm/doctrine-mapping'>
                    <xsl:attribute name='strategy'>AUTO</xsl:attribute>
                </xsl:element>
                <xsl:element name='sequence-generator' namespace='http://doctrine-project.org/schemas/orm/doctrine-mapping'>
                    <xsl:attribute name='sequence-name'>
                        <xsl:call-template name='lower-case'>
                            <xsl:with-param name='value' select='@name'/>
                        </xsl:call-template>
                        <xsl:text>_seq</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name='allocation-size'>100</xsl:attribute>
                    <xsl:attribute name='initial-value'>1</xsl:attribute>
                </xsl:element>
            </xsl:element>
            <xsl:apply-templates select='fields/field'/>
            <xsl:apply-templates select='fields/field' mode='fieldEntityReference'/>
        </xsl:element>
    </xsl:template>

    <!--
    Add a field mapping to an entity.
    -->
    <xsl:template match='object/fields/field'>
        <xsl:element name='field' namespace='http://doctrine-project.org/schemas/orm/doctrine-mapping'>
            <xsl:attribute name='name'>
                <xsl:call-template name='camel-back'>
                    <xsl:with-param name='value' select='@name'/>
                </xsl:call-template>
            </xsl:attribute>
            <xsl:attribute name='column'>
                <xsl:value-of select='parent::node()/parent::node()/orm/@columnEscapeCharacter'/>
                <xsl:value-of select='@name'/>
                <xsl:value-of select='parent::node()/parent::node()/orm/@columnEscapeCharacter'/>
            </xsl:attribute>
            <xsl:attribute name='type'><xsl:apply-templates select='self::node()' mode='fieldTypeAttributeValue'/></xsl:attribute>
            <xsl:apply-templates select='self::node()' mode='fieldNullableAttribute'/>
            <xsl:apply-templates select='self::node()' mode='fieldLengthAttribute'/>
            <xsl:apply-templates select='self::node()' mode='fieldUniqueAttribute'/>
            <xsl:apply-templates select='self::node()' mode='fieldScalePrecisionAttribute'/>
        </xsl:element>
    </xsl:template>

    <!--
    Add the lower-case value of @datatype as type by default.
    -->
    <xsl:template match='object/fields/field' mode='fieldTypeAttributeValue'>
        <xsl:call-template name='lower-case'>
            <xsl:with-param name='value' select='@datatype'/>
        </xsl:call-template>
    </xsl:template>

    <!--
    Add string as type for DATEINTERVAL, FILE and VARCHAR datatypes.
    -->
    <xsl:template match='object/fields/field[@datatype = "DATEINTERVAL" or @datatype = "FILE" or @datatype = "VARCHAR"]' mode='fieldTypeAttributeValue'>
        <xsl:text>string</xsl:text>
    </xsl:template>

    <!--
    Add text as type for HTML datatype.
    -->
    <xsl:template match='object/fields/field[@datatype = "HTML"]' mode='fieldTypeAttributeValue'>
        <xsl:text>text</xsl:text>
    </xsl:template>

    <!--
    Add array as type for SET datatype.
    -->
    <xsl:template match='object/fields/field[@datatype = "SET"]' mode='fieldTypeAttributeValue'>
        <xsl:text>array</xsl:text>
    </xsl:template>

    <!--
    Add nullable attribute with true by default.
    -->
    <xsl:template match='object/fields/field' mode='fieldNullableAttribute'>
        <xsl:attribute name='nullable'>true</xsl:attribute>
    </xsl:template>

    <!--
    Add nullable attribute with false by when the field is required.
    -->
    <xsl:template match='object/fields/field[@required = "true"]' mode='fieldNullableAttribute'>
        <xsl:attribute name='nullable'>false</xsl:attribute>
    </xsl:template>

    <!--
    Don't add a length attribute by default.
    -->
    <xsl:template match='object/fields/field' mode='fieldLengthAttribute'/>

    <!--
    Add a length attribute with the maximum length of a DATEINTERVAL according to the ISO-8601 specification.
    -->
    <xsl:template match='object/fields/field[@datatype = "DATEINTERVAL"]' mode='fieldLengthAttribute'>
        <xsl:attribute name='length'>41</xsl:attribute>
    </xsl:template>

    <!--
    Add a length attribute for a VARCHAR datatype.
    -->
    <xsl:template match='object/fields/field[@datatype = "VARCHAR" and @length]' mode='fieldLengthAttribute'>
        <xsl:attribute name='length'><xsl:value-of select='@length'/></xsl:attribute>
    </xsl:template>

    <!--
    Don't add a unique attribute by default.
    -->
    <xsl:template match='object/fields/field' mode='fieldUniqueAttribute'/>

    <!--
    Add a unique attribute when configured as 'true'.
    -->
    <xsl:template match='object/fields/field[@unique = "true"]' mode='fieldUniqueAttribute'>
        <xsl:attribute name='unique'>true</xsl:attribute>
    </xsl:template>

    <!--
    Don't add scale and precision attributes by default.
    -->
    <xsl:template match='object/fields/field' mode='fieldScalePrecisionAttribute'/>

    <!--
    Add scale and precision attributes for a DECIMAL datatype.
    -->
    <xsl:template match='object/fields/field[@datatype = "DECIMAL" and @length and @precision]' mode='fieldScalePrecisionAttribute'>
        <xsl:attribute name='scale'><xsl:value-of select='@length'/></xsl:attribute>
        <xsl:attribute name='precision'><xsl:value-of select='@precision'/></xsl:attribute>
    </xsl:template>

    <!--
    Don't add a field mapping when a field is defined in a orm/field-defined node or are an object reference.
    -->
    <xsl:template match='object/fields/field[parent::node()/parent::node()/orm/field-defined[@name = current()/@name]] | object/fields/field[starts-with(@datatype, "OBJECT.")]'/>

    <!--
    Don't add a entity reference for a field by default.
    -->
    <xsl:template match='object/fields/field' mode='fieldEntityReference'/>

    <!--
    Don't add an entity reference for a field that has a @datatype starting with 'OBJECT.'.
    -->
    <xsl:template match='object/fields/field[starts-with(@datatype, "OBJECT.")]' mode='fieldEntityReference'>
        <xsl:element name='many-to-one' namespace='http://doctrine-project.org/schemas/orm/doctrine-mapping'>
            <xsl:attribute name='field'><xsl:value-of select='@name'/></xsl:attribute>
            <xsl:attribute name='target-entity'><xsl:value-of select='substring(@datatype, 8)'/></xsl:attribute>
        </xsl:element>
    </xsl:template>

    <!--
    XSLT 1.0 utility templates for XSLT 2.0 functions.
    -->

    <!--
    Transform a value to upper-case.
    -->
    <xsl:template name='upper-case'>
        <xsl:param name='value'/>

        <xsl:value-of select='translate($value, "abcdefghijklmnopqrstuvwxyz", "ABCDEFGHIJKLMNOPQRSTUVWXYZ")'/>
    </xsl:template>

    <!--
    Transform a value to lower-case.
    -->
    <xsl:template name='lower-case'>
        <xsl:param name='value'/>

        <xsl:value-of select='translate($value, "ABCDEFGHIJKLMNOPQRSTUVWXYZ", "abcdefghijklmnopqrstuvwxyz")'/>
    </xsl:template>

    <!--
    Transform a value to camelBack.
    -->
    <xsl:template name='camel-back'>
        <xsl:param name='value'/>

        <xsl:choose>
            <xsl:when test='contains($value, "_")'>
                <xsl:call-template name='lower-case'>
                    <xsl:with-param name='value' select='substring-before($value, "_")'/>
                </xsl:call-template>
                <xsl:call-template name='camel-case'>
                    <xsl:with-param name='value' select='substring-after($value, "_")'/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name='lower-case'>
                    <xsl:with-param name='value' select='$value'/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!--
    Transform a value to CamelCase.
    -->
    <xsl:template name='camel-case'>
        <xsl:param name='value'/>

        <xsl:choose>
            <xsl:when test='contains($value, "_")'>
                <xsl:call-template name='uc-first'>
                    <xsl:with-param name='value' select='substring-before($value, "_")'/>
                </xsl:call-template>
                <xsl:call-template name='camel-case'>
                    <xsl:with-param name='value' select='substring-after($value, "_")'/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name='uc-first'>
                    <xsl:with-param name='value' select='$value'/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!--
    Transform the first character of a value to upper-case and all other characters to lower-case.
    -->
    <xsl:template name='uc-first'>
        <xsl:param name='value'/>

        <xsl:call-template name='upper-case'>
            <xsl:with-param name='value' select='substring($value, 1, 1)'/>
        </xsl:call-template>
        <xsl:call-template name='lower-case'>
            <xsl:with-param name='value' select='substring($value, 2, string-length($value) - 1)'/>
        </xsl:call-template>
    </xsl:template>

</xsl:stylesheet>
