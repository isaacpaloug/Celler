<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">

    <xsl:output method="html" version="5"/>

    <xsl:template match="celler">
        <html>
            <head>
                <meta charset="utf-8"/>
                <title>Celler</title>
                <link rel="stylesheet" href="celler.css"/>
                <link rel="icon" href="pics/vino.ico"/>
            </head>
            <body>
                <xsl:apply-templates select="factures/factura"/>
            </body>
        </html>
    </xsl:template>

    <xsl:template match="factura">
        <div id="pag">
            <div class="logo">Celler Can Palou</div>
            <div id="infoclient">
                <xsl:apply-templates select="comprador"/>
            </div>
            <div id="infofactura">
                <div>Informació Factura
                    <div id="codifactura" style="clear: both;">[Nº <xsl:value-of select="@numero"/>]
                    </div>
                </div>
                <table>
                    <tr>
                        <td class="petit"><b>Codi Producte</b></td>
                        <td class="petit"><b>Nom</b></td>
                        <td class="petit"><b>Preu unitari</b></td>
                        <td class="petit"><b>Unitats</b></td>
                        <td class="petit"><b>Preu total</b></td>
                    </tr>
                    <xsl:call-template name="llista">
                        <xsl:with-param name="contador" select="1"/>
                    </xsl:call-template>
                    <tr>
                        <td colspan="4" class="total"><b>TOTAL:</b></td>
                        <td class="aMa total">
                            <xsl:call-template name="calcular">
                                <xsl:with-param name="llista_compra" select="unitats"/>
                                <xsl:with-param name="total" select="0"/>
                            </xsl:call-template>
                        </td>
                    </tr>
                </table>
            </div>
            <div id="peu" style="clear: both;">
                <div id="direccio">
                    <div>Celler Can Palou
                        <br/>
                        Carrer Albeniz, 24
                        <br/>
                        07420 Sa Pobla
                        <br/>
                        CIF: P78
                        <br/>
                        <br/>
                    </div>
                    <div class="blocfirma">SIGNATURA:
                        <br/>
                        <div class="firma">
                            <xsl:call-template name="firma"/>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </xsl:template>

    <xsl:template match="comprador">
        <xsl:variable name="codi_client" select="@codi"/>
        <xsl:variable name="client" select="//client[@codi = $codi_client]"/>
        <div>Informació Client [CODI <xsl:value-of select="$codi_client"/>] </div>
        <br/>
        <div> <b>Nom i cognoms:</b> <div class="aMa">
            <xsl:value-of select="concat($client/cognoms, ', ', $client/nom)"/>
        </div>
        </div>
        <div> <b> Telefons: </b>
            <xsl:call-template name="telefons">
                <xsl:with-param name="contador" select="1"/>
            </xsl:call-template>
        </div>

    </xsl:template>

    <xsl:template name="telefons">
        <xsl:param name="contador"/>
        <xsl:variable name="codi_client" select="@codi"/>
        <xsl:variable name="client" select="//clients/client[@codi = $codi_client]"/>
        <xsl:variable name="tlf" select="$client/contacte/telefon[$contador]"/>
        <xsl:choose>
            <xsl:when test="$tlf">
                <div class="telefons">
                    <xsl:value-of select="$tlf"/>
                    <xsl:text> (</xsl:text>
                    <xsl:value-of select="$tlf/@tipus"/>
                    <xsl:text>) </xsl:text>
                </div>
                <xsl:call-template name="telefons">
                    <xsl:with-param name="contador" select="$contador + 1"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:if test="$contador &lt;= 3">
                    <div class="telefons buit"> </div>
                    <xsl:call-template name="telefons">
                        <xsl:with-param name="contador" select="$contador + 1"/>
                    </xsl:call-template>
                </xsl:if>

            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <xsl:template name="llista">
        <xsl:param name="contador"/>
        <xsl:variable name="codi_producte" select="unitats[$contador]/@codi"/>
        <xsl:variable name="producte" select="//productes/producte[@codi = $codi_producte]"/>
        <xsl:variable name="unitats" select="unitats[$contador]"/>
        <xsl:variable name="preu" select="$producte/@preu"/>
        <xsl:variable name="total" select="$preu * $unitats"/>
        <xsl:choose>
            <xsl:when test="$unitats">
                <tr>
                    <td class="aMa">
                        <xsl:value-of select="$codi_producte"/>
                    </td>
                    <td class="aMa">
                        <xsl:value-of select="$producte"/>
                    </td>
                    <td class="aMa">
                        <xsl:value-of select="format-number(number($preu), '.00 €')"/>
                    </td>
                    <td class="aMa">
                        <xsl:value-of select="$unitats"/>
                    </td>
                    <td class="aMa">
                        <xsl:value-of select="format-number(number($total), '.00 €')"/>
                    </td>
                </tr>
                <xsl:call-template name="llista">
                    <xsl:with-param name="contador" select="$contador + 1"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:if test="$contador &lt;= count(//producte)">
                    <tr>
                        <td/>
                        <td/>
                        <td/>
                        <td/>
                        <td/>
                    </tr>
                    <xsl:call-template name="llista">
                        <xsl:with-param name="contador" select="$contador + 1"/>
                    </xsl:call-template>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="calcular">
        <xsl:param name="llista_compra"/>
        <xsl:param name="total"/>
        <xsl:choose>
            <xsl:when test="$llista_compra">
                <xsl:variable name="unitats" select="$llista_compra[1]/."/>
                <xsl:variable name="codi_producte" select="$llista_compra[1]/@codi"/>
                <xsl:variable name="preu" select="//producte[@codi=$codi_producte]/@preu"/>
                <xsl:call-template name="calcular">
                    <xsl:with-param name="llista_compra" select="$llista_compra[position() > 1]"/>
                    <xsl:with-param name="total" select="$total + $unitats * number($preu)"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="format-number($total, '#.00€')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="firma">
        <xsl:variable name="codiClient" select="comprador/@codi"/>
        <xsl:variable name="Client" select="//client[@codi = $codiClient]"/>
        <xsl:value-of select="substring($Client/nom,1,1)"/>.
        <xsl:value-of select="$Client/cognoms"/>
    </xsl:template>


</xsl:stylesheet>