<?xml version="1.0" encoding="ISO-8859-1"?>
<!DOCTYPE stylesheet [
    <!ENTITY tilegraphic "&#xa0;" >
    <!ENTITY literalspace "&#x20;" >
]>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output type="html" encoding="utf-8"/>

<xsl:template match="/MapGen">
    <html>
        <head>
            <title> MapGen </title>
            <style type="text/css">
                body        { background: #000; color: #fff; }

                table.map   { border: 1px solid #666; }
                <xsl:if test="/MapGen/option[@name='bounding_box'] and /MapGen/option[@name='cell_size']">table.map {
                     width: <xsl:value-of select="substring-before(/MapGen/option[@name='cell_size']/@value, 'x')*substring-before(/MapGen/option[@name='bounding_box']/@value, 'x')"/>px;
                    height: <xsl:value-of select=" substring-after(/MapGen/option[@name='cell_size']/@value, 'x')* substring-after(/MapGen/option[@name='bounding_box']/@value, 'x')"/>px;
                }</xsl:if>

                td.tile     { width: 15px; height: 15px; background: #222; border: 1px solid #333; }
                <xsl:if test="/MapGen/option[@name='cell_size']">td.tile {
                     width: <xsl:value-of select="substring-before(/MapGen/option[@name='cell_size']/@value, 'x')"/>px;
                    height: <xsl:value-of select=" substring-after(/MapGen/option[@name='cell_size']/@value, 'x')"/>px;
                }</xsl:if>

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
                                <xsl:choose>
                                    <xsl:when test="/MapGen/option[@name='tile_size']/@value = '10 ft'">
                                        <!-- If you know of other good standard sizes to support, please let me know.  -Paul -->
                                    </xsl:when>
                                    <xsl:otherwise>&tilegraphic;</xsl:otherwise>
                                </xsl:choose>
                            </td>
                        </xsl:for-each>
                    </tr>
                </xsl:for-each>
            </table>
        </body>
    </html>
</xsl:template>

</xsl:stylesheet>
