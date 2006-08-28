<?xml version="1.0" encoding="ISO-8859-1"?>
<!DOCTYPE stylesheet [
    <!ENTITY tilegraphic "&#xa0;" >
    <!ENTITY literalspace "&#x20;" >
]>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output type="html" encoding="utf-8"/>

<!--
<xsl:for-each select="option">
    <xsl:if test="@name='bounding_box'">
        <xsl:variable name="bx" select="substring-before(@value, 'x')"/>
        <xsl:variable name="by" select=" substring-after(@value, 'x')"/>
    </xsl:if>
</xsl:for-each>
-->

<xsl:template match="/MapGen">
    <html>
        <head>
            <title> MapGen </title>
            <style type="text/css">
                body        { background: #000; color: #fff; }

                table.map   { border: 1px solid #666; }
                <xsl:for-each select="option">
                    <xsl:if test="@name='bounding_box'">
                        <xsl:variable name="bx" select="substring-before(@value, 'x')"/>
                        <xsl:variable name="by" select=" substring-after(@value, 'x')"/>
                        <xsl:for-each select="../option">
                            <xsl:if test="@name='cell_size'">table.map {
                                 width: <xsl:value-of select="substring-before(@value, 'x')*$bx"/>px;
                                height: <xsl:value-of select=" substring-after(@value, 'x')*$by"/>px;
                            }</xsl:if>
                        </xsl:for-each>
                    </xsl:if>
                </xsl:for-each>

                td.tile     { width: 15px; height: 15px; background: #222; border: 1px solid #333; }
                <xsl:for-each select="option">
                    <xsl:if test="@name='cell_size'">td.tile {
                         width: <xsl:value-of select="substring-before(@value, 'x')"/>px;
                        height: <xsl:value-of select=" substring-after(@value, 'x')"/>px;
                    }</xsl:if>
                </xsl:for-each>

                td.corridor { background: #ccc; border: 1px dashed #bbb; }
                td.room     { background: #fff; border: 1px dashed #ddd; }

                td.northwall { border-top:    1px solid #333; }
                td.eastwall  { border-right:  1px solid #333; }
                td.southwall { border-bottom: 1px solid #333; }
                td.westwall  { border-left:   1px solid #333; }

                td.northdoor { border-top:    2px solid brown; }
                td.eastdoor  { border-right:  2px solid brown; }
                td.southdoor { border-bottom: 2px solid brown; }
                td.westdoor  { border-left:   2px solid brown; }
            </style>
        </head>
        <body>
            <table cellspacing="0" cellpadding="0" class="map">
                <xsl:for-each select="map/row">
                    <tr>
                        <xsl:for-each select="tile">
                            <td>
                                <xsl:attribute name="class">tile <xsl:value-of select="@type"/> <xsl:for-each select="closure">
                                    <xsl:text> </xsl:text>
                                    <xsl:value-of select="@dir"/>
                                    <xsl:value-of select="@type"/>
                                </xsl:for-each>
                                <xsl:if test="@locked='yes'">
                                    locked
                                </xsl:if>
                                </xsl:attribute>
                                &tilegraphic;
                            </td>
                        </xsl:for-each>
                    </tr>
                </xsl:for-each>
            </table>
        </body>
    </html>
</xsl:template>

</xsl:stylesheet>
