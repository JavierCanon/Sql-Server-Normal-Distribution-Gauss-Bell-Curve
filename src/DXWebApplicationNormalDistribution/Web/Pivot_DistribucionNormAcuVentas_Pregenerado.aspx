<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Pivot_DistribucionNormAcuVentas_Pregenerado.aspx.cs"
    Inherits="BINumber_Web.Web.Auditoria.Queries.Pivot_DistribucionNormAcuVentas_Pregenerado" %>

<%@ Register Assembly="DevExpress.XtraCharts.v18.2.Web, Culture=neutral, PublicKeyToken=b88d1754d700e49a"
    Namespace="DevExpress.XtraCharts.Web" TagPrefix="dx" %>

<%@ Register Assembly="DevExpress.Web.v18.2, Version=18.2.5.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a"
    Namespace="DevExpress.Web" TagPrefix="dx" %>

<%@ Register Assembly="DevExpress.Web.ASPxPivotGrid.v18.2, Version=18.2.5.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a"
    Namespace="DevExpress.Web.ASPxPivotGrid" TagPrefix="dx" %>

<%@ Register TagPrefix="dx" Namespace="DevExpress.XtraCharts" Assembly="DevExpress.XtraCharts.v18.2, Version=18.2.5.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" %>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">

        <h1 class="bg-info">BINumber <i class="fa fa-sort-numeric-up"></i>
        <small>Consulta Pivote Distribucion Normal Acumulada Ventas</small>
    </h1>


    <hr />

    <dx:ASPxPivotGrid ID="pivotGrid" runat="server" DataSourceID="masterDataSource"
        Caption="Pivote Distribucion Normal Acumulada de Ventas"
        SaveStateToCookiesID="Pivot_DistribucionNormAcuVentasMensual"
        Width="100%"
        CustomizationFieldsVisible="False"
        OptionsPager-ShowSeparators="True"
        OptionsPager-RowsPerPage="100"
        EnableRowsCache="True"
        SaveStateToCookies="False">

        <Fields>
            <%--
        OptionsChartDataSource-ShowColumnCustomTotals="False"
        OptionsChartDataSource-ShowColumnGrandTotals="False"
        OptionsChartDataSource-ShowColumnTotals="False"
        OptionsChartDataSource-ShowRowCustomTotals="False"
        OptionsChartDataSource-ShowRowGrandTotals="False"
        OptionsChartDataSource-ShowRowTotals="False"


        OnCustomUnboundFieldData="pivotGrid_CustomUnboundFieldData"
        OnCustomCellDisplayText="pivotGrid_CustomCellDisplayText"
        OnCustomCellStyle="ASPxPivotGrid1_CustomCellStyle"

           <dx:PivotGridField Area="ColumnArea" AllowedAreas="ColumnArea" AreaIndex="1" FieldName="Fecha"
                ID="PivotGridField_FECHAYEAR"
                Caption="Año" GroupInterval="DateYear">
            </dx:PivotGridField>

            <dx:PivotGridField Area="ColumnArea" AllowedAreas="ColumnArea" AreaIndex="2" FieldName="Fecha" ID="PivotGridField_FECHAMONTH"
                Caption="Mes" GroupInterval="DateMonth">
            </dx:PivotGridField>

            <dx:PivotGridField Area="ColumnArea" AllowedAreas="ColumnArea" AreaIndex="3" FieldName="Fecha" ID="PivotGridField_FECHADAY"
                Caption="Dia" GroupInterval="DateDay">
            </dx:PivotGridField>

            --%>

            <dx:PivotGridField Area="RowArea" AllowedAreas="RowArea" AreaIndex="1"
                FieldName="Fecha" ID="PivotGridField_FechaMes" GroupInterval="DateMonthYear"
                Caption="Mes">
            </dx:PivotGridField>

            <dx:PivotGridField Area="RowArea" AllowedAreas="RowArea" AreaIndex="2"
                FieldName="Fecha" ID="PivotGridField_FechaDia" GroupInterval="DateDay"
                Caption="Dia">
            </dx:PivotGridField>

            <dx:PivotGridField Area="DataArea" AreaIndex="1" FieldName="DistNormalAc" ID="PivotGridField_DistNormalAc"
                CellFormat-FormatString="{0:n15}" CellFormat-FormatType="Custom" EmptyValueText="0" EmptyCellText="0"
                Caption="DistNormalAc" AllowedAreas="DataArea" SummaryType="Average" />

            <dx:PivotGridField Area="DataArea" AreaIndex="2" FieldName="Rank" ID="PivotGridField_Rank"
                CellFormat-FormatString="{0:n3}" CellFormat-FormatType="Custom" EmptyValueText="0" EmptyCellText="0"
                Caption="Rank" AllowedAreas="DataArea" SummaryType="Average" />

            <dx:PivotGridField Area="DataArea" AreaIndex="3" FieldName="ValorBruto" ID="PivotGridField_ValorBruto"
                CellFormat-FormatString="{0:n0}" CellFormat-FormatType="Custom" EmptyValueText="0" EmptyCellText="0"
                Caption="ValorBruto" AllowedAreas="DataArea" SummaryType="Sum" />


            <%-- 

                            <dx:PivotGridField Area="DataArea" AreaIndex="5" FieldName="PartUtilidad" ID="PivotGridFieldPART_Profit" EmptyValueText="0" EmptyCellText="0"
                Caption="Part.Ingreso" CellFormat-FormatString="{0:p}" CellFormat-FormatType="Custom" UnboundType="Decimal" AllowedAreas="DataArea" />


            <dx:PivotGridField Area="DataArea" AreaIndex="6" FieldName="Arriendo" ID="PGF_Arriendo" CellFormat-FormatString="{0:n0}" CellFormat-FormatType="Custom" EmptyValueText="0" EmptyCellText="0"
                Caption="Arriendo" AllowedAreas="DataArea" />

            --%>
        </Fields>
        <Groups></Groups>
        <OptionsView ShowHorizontalScrollBar="True" ShowFilterHeaders="True"
            ShowContextMenus="true" ShowRowGrandTotals="true" ShowRowTotals="True"
            ShowColumnGrandTotals="True" ShowColumnTotals="True" ColumnTotalsLocation="Far"
            ShowTotalsForSingleValues="True" />
        <Prefilter Enabled="True" />
        <OptionsBehavior />
        <OptionsLayout />
        <OptionsCustomization />
        <OptionsFilter />
        <OptionsData AutoExpandGroups="False" />
        <OptionsDataField />
        <OptionsPager></OptionsPager>
        <OptionsChartDataSource MaxAllowedPointCountInSeries="1000" />
    </dx:ASPxPivotGrid>
    <hr />

    <dx:WebChartControl ID="WebChartControl1" runat="server" CrosshairEnabled="True"
        DataSourceID="masterDataSource" Width="900px" Height="600px">
        <DiagramSerializable>
            <dx:XYDiagram>
                <AxisX Title-Text="ValorBruto" Title-Visibility="True" >
                    <Label TextPattern="{A:n2}"></Label>
                </AxisX>
                <AxisY Title-Text="DistNormalAc" Title-Visibility="True" Visibility="false">
                    <Label TextPattern="{V:n0}"></Label>
                    <NumericScaleOptions />
                </AxisY>
            </dx:XYDiagram>
        </DiagramSerializable>

        <Legend MaxHorizontalPercentage="30" Name="Default Legend" Visibility="False"></Legend>

        <SeriesSerializable>
            <dx:Series Name="Series 1" ArgumentDataMember="ValorBruto" ValueDataMembersSerializable="DistNormalAc" ArgumentScaleType="Numerical"
                CrosshairEnabled="True" ValueScaleType="Numerical" CrosshairLabelPattern="{A:n3}|{V:n}">
                <ViewSerializable>
                    <dx:SplineSeriesView ColorEach="True"></dx:SplineSeriesView>
                </ViewSerializable>
                <LabelSerializable>
                    <dx:PointSeriesLabel TextPattern="{A:n3}|{V:n}"></dx:PointSeriesLabel>
                </LabelSerializable>
            </dx:Series>
        </SeriesSerializable>

        <SeriesTemplate ArgumentScaleType="Numerical" ValueScaleType="Numerical">

            <ViewSerializable>
                <dx:SplineSeriesView>
                    <LineMarkerOptions Size="8"></LineMarkerOptions>
                </dx:SplineSeriesView>
            </ViewSerializable>
            <CrosshairTextOptions  />
        </SeriesTemplate>
        <Titles>
            <dx:ChartTitle Text="Distribucion de la Normal Acumulada"></dx:ChartTitle>
        </Titles>
    </dx:WebChartControl>

    <hr />
    <dx:ASPxPageControl ID="ASPxPageControlExportar" runat="server" ActiveTabIndex="0"
        TabSpacing="3px"
        Width="300">
        <ContentStyle>
        </ContentStyle>
        <TabPages>
            <dx:TabPage Text="Exportar Reporte">
                <ContentCollection>
                    <dx:ContentControl ID="ContentControl5" runat="server">
                        <table>
                            <tr>
                                <td><b>Exportar a:</b></td>
                                <td>
                                    <dx:ASPxComboBox ID="listExportFormat" runat="server" Style="vertical-align: middle"
                                        SelectedIndex="0" ValueType="System.String" Width="61px"
                                        ShowShadow="False">
                                        <Items>
                                            <dx:ListEditItem Text="Excel" Value="0" />
                                            <dx:ListEditItem Text="Texto CSV" Value="1" />
                                            <dx:ListEditItem Text="Html" Value="2" />
                                        </Items>
                                        <LoadingPanelImage></LoadingPanelImage>
                                        <ValidationSettings>
                                            <ErrorFrameStyle>
                                                <ErrorTextPaddings />
                                            </ErrorFrameStyle>
                                        </ValidationSettings>
                                    </dx:ASPxComboBox>
                                </td>
                                <td>
                                    <dx:ASPxButton ID="buttonSaveAs" runat="server" ToolTip="Exportar y guardar" Style="vertical-align: middle;"
                                        OnClick="buttonSaveAs_Click" Text="Guardar" Width="51px" />
                                </td>
                                <td>
                                    <dx:ASPxButton ID="buttonOpen" runat="server" ToolTip="Exportar y abrir" Style="vertical-align: middle"
                                        OnClick="buttonOpen_Click" Text="Abrir" Width="51px" />
                                </td>
                            </tr>
                        </table>
                    </dx:ContentControl>
                </ContentCollection>
            </dx:TabPage>
            <dx:TabPage Text="Opciones">
                <ContentCollection>
                    <dx:ContentControl ID="ContentControl6" runat="server">
                        <table border="0" cellpadding="3" cellspacing="0">
                            <tr>
                                <td rowspan="5" valign="top" style="width: 106px"><strong>Opciones: </strong></td>
                                <td style="width: 180px">
                                    <asp:CheckBox ID="checkPrintHeadersOnEveryPage" runat="server" Text="Imprimir encabezados en cada página" /></td>
                            </tr>
                            <tr>
                                <td style="width: 180px">
                                    <asp:CheckBox ID="checkPrintFilterHeaders" runat="server" Text="Imprimir encabezados de filtros"
                                        Checked="True" /></td>
                            </tr>
                            <tr>
                                <td style="width: 180px">
                                    <asp:CheckBox ID="checkPrintColumnHeaders" runat="server" Text="Imprimir encabezados de columnas"
                                        Checked="True" /></td>
                            </tr>
                            <tr>
                                <td style="width: 180px">
                                    <asp:CheckBox ID="checkPrintRowHeaders" runat="server" Text="Imprimir encabezados de filas" Checked="True" /></td>
                            </tr>
                            <tr>
                                <td style="width: 180px">
                                    <asp:CheckBox ID="checkPrintDataHeaders" runat="server" Text="Imprimir encabezados de datos"
                                        Checked="True" /></td>
                            </tr>
                        </table>
                    </dx:ContentControl>
                </ContentCollection>
            </dx:TabPage>
        </TabPages>
        <Paddings Padding="2px" PaddingLeft="5px" PaddingRight="5px" />
    </dx:ASPxPageControl>

    <dx:ASPxPivotGridExporter ID="ASPxPivotGridExporter1" runat="server" ASPxPivotGridID="pivotGrid" Visible="False" />

    <%--
           @CodEmpresa varchar(10)
          ,@Empresa varchar(50)
          ,@CodDepartamento varchar(10)
          ,@Departamento varchar(50)
          ,@CodSorteo varchar(10)
          ,@Sorteo varchar(50)
          ,@NumeroGanador char(4)
          ,@NumeroApostado char(4)
          ,@CodSigno varchar(10)
          ,@Signo varchar(50)
          ,@CodSignoGanador varchar(10)
          ,@SignoGanador varchar(50)

    --%>

    <asp:SqlDataSource ID="masterDataSource" runat="server" EnableCaching="true" CacheDuration="300"
        CacheExpirationPolicy="Sliding" ConnectionString="<%$ ConnectionStrings:MsSqlServer.Main %>"
        SelectCommandType="Text" 
        OnSelecting="DBMainDataSources_Selecting" OnInit="DBMainDataSources_Init"
        CancelSelectOnNullParameter="false">
        <SelectParameters>



            <%--
            <asp:ControlParameter ControlID="ctl00$ContentMain$ASPxComboBoxEmpresa" PropertyName="Value" Name="Empresa"
                DbType="String" Size="50"
                ConvertEmptyStringToNull="true" />

            <asp:ControlParameter ControlID="ctl00$ContentMain$ASPxComboBoxDepartamento" PropertyName="Value" Name="Departamento"
                DbType="String" Size="50"
                ConvertEmptyStringToNull="true" />

            <asp:ControlParameter ControlID="ctl00$ContentMain$ASPxComboBoxSorteo" PropertyName="Value" Name="Sorteo"
                DbType="String" Size="50"
                ConvertEmptyStringToNull="true" />

            <asp:ControlParameter ControlID="ctl00$ContentMain$ASPxComboBoxSigno" PropertyName="Value" Name="Signo"
                DbType="String" Size="50"
                ConvertEmptyStringToNull="true" />
                --%>
        </SelectParameters>

    </asp:SqlDataSource>
    <%-- 
    <asp:SqlDataSource runat="server" ID="SqlDataSourceEmpresa" EnableCaching="true" CacheDuration="300"
        CacheExpirationPolicy="Sliding" ConnectionString="<%$ ConnectionStrings:MsSqlServer.Main %>"
        SelectCommandType="Text" SelectCommand="
       SELECT CodEmpresa,
       [Empresa]
  FROM [dbo].[Empresa]
    ORDER BY Empresa
        
    "></asp:SqlDataSource>

    <asp:SqlDataSource runat="server" ID="SqlDataSourceDepartamento" EnableCaching="true" CacheDuration="300"
        CacheExpirationPolicy="Sliding" ConnectionString="<%$ ConnectionStrings:MsSqlServer.Main %>"
        SelectCommandType="Text" SelectCommand="
       SELECT CodDepartamento,
      [Departamento]
  FROM [dbo].[Departamento]
  ORDER BY Departamento    
    "></asp:SqlDataSource>

    <asp:SqlDataSource runat="server" ID="SqlDataSourceSorteo" EnableCaching="true" CacheDuration="300"
        CacheExpirationPolicy="Sliding" ConnectionString="<%$ ConnectionStrings:MsSqlServer.Main %>"
        SelectCommandType="Text" SelectCommand="
       SELECT CodSorteo,
       [Sorteo]
  FROM [dbo].[Sorteo]
ORDER BY Sorteo
    
    "></asp:SqlDataSource>

    <asp:SqlDataSource runat="server" ID="SqlDataSourceSigno" EnableCaching="true" CacheDuration="300"
        CacheExpirationPolicy="Sliding" ConnectionString="<%$ ConnectionStrings:MsSqlServer.Main %>"
        SelectCommandType="Text" SelectCommand="
SELECT CONVERT(INT,CodSigno) CodSigno
      ,[Signo]
  FROM [dbo].[Signo] 
        
    "></asp:SqlDataSource>
    --%>


</asp:Content>

