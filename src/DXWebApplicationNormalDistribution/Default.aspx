<%@ Page Language="C#" AutoEventWireup="true" MasterPageFile="~/Site.master" CodeBehind="Default.aspx.cs" Inherits="DXWebApplicationNormalDistribution._Default" %>

<asp:Content ID="Content" ContentPlaceHolderID="MainContent" runat="server">
    <h2>SALES DEMOS </h2>

    <h3>Normal Distribution</h3>
    <ul>
        <li>
            <p>
                <a href="Web/Pivot_DistribucionNormVentas_Pregenerado.aspx?t=RPANO_DistNormalVentas_Anual_2017" target="_blank">Anual Sales</a>
            </p>

            <p>
                <a href="Web/Pivot_DistribucionNormVentas_Pregenerado.aspx?t=RPMES_DistNormalVentas_Mensual_2017_10" target="_blank">Month Sales</a>
            </p>

        </li>
    </ul>


    <h3>Cumulative Normal Distribution</h3>
    <ul>
        <li>
            <p>
                <a href="Web/Pivot_DistribucionNormAcuVentas_Pregenerado.aspx?t=RPANO_DistNormalAcumVentas_Anual_2017" target="_blank">Anual Sales</a>
            </p>

            <p>
                <a href="Web/Pivot_DistribucionNormAcuVentas_Pregenerado.aspx?t=RPMES_DistNormalAcumVentas_Mensual_2017_10" target="_blank">Month Sales</a>
            </p>

        </li>
    </ul>


</asp:Content>
