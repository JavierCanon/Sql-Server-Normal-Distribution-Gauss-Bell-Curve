using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data.SqlClient;
using DevExpress.Web;
using DevExpress.Web.ASPxPivotGrid;
using DevExpress.Utils;
using DevExpress.XtraPivotGrid;

namespace BINumber_Web.Web.Auditoria.Queries
{
    public partial class Pivot_DistribucionNormVentas_Pregenerado : Page
    {


        protected string queryTitle = "";

        //variables globales
        const string fileNameToExport = "Pivot_DistribucionNormVentasMensual";
        const int setMinReportDayCount = 7;
        const int setMaxReportDayCount = 31;

        protected void Page_InitComplete(object sender, EventArgs e)
        {
            if (!SL.Permissions.GetPermission(
                SL.UserPermissionTypeEnum.BINUMBER_ACCESO_DISTRIBUCION_NORMAL_VENTAS
                , Session
                , Global.DAL.GetConnectionStringDBData()))
            {
                Response.Redirect("~/ErrorPermission.html", true);
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {

            if (!IsCallback && !IsPostBack)
            {

                // set query subtitle
                if (Request.QueryString["m"] != null && Request.QueryString["a"] != null)
                {
                    queryTitle = Request.QueryString["a"] + " - " + Request.QueryString["m"];
                }

            }


        }

        #region Filters

        protected void ASPxButtonSearch_Click(object sender, EventArgs e)
        {
            Page.Validate();

            //  if(IsPostBack && ASPxEdit.ValidateEditorsInContainer(this))
            if (Page.IsValid)
            {

                // dont need this because the parameter is now a control:
                // masterDataSource.SelectParameters["Search"].DefaultValue = ASPxTextBoxSearch.Value.ToString();
                //masterDataSource.DataBind();
                //ASPxGridView1.DataBind();




            }
        }

        #endregion Filters


        #region DataSources

        protected void DBMainDataSources_Selecting(object sender, SqlDataSourceSelectingEventArgs e)
        {
            e.Command.CommandTimeout = 60 * 10;
        }

        protected void DBMainDataSources_Init(object sender, EventArgs e)
        {
            // (sender as SqlDataSource).ConnectionString = SIMI.Global.GetConnectionStringDBData();


            string tsql = "", stable = "";

            // set table name

            if (Request.QueryString["t"] != null)
            {

                stable = Request.QueryString["t"];


                tsql = @"
SELECT [Rn]
      ,[YAxis]
      ,[NormalDist]
      ,[Rank]
      ,[SUMValorBruto]
  FROM " + stable + @"       
";



                (sender as SqlDataSource).SelectCommand = tsql;
            }

        }

        #endregion DataSources

        /*
        protected void CBPuntos_Callback(object sender, DevExpress.Web.CallbackEventArgsBase e)
        {
            SqlDataSourceCbPuntos.DataBind();
            (sender as ASPxComboBox).DataBindItems();


        }
        */

        #region Pivotgrid

        void GroupsExpandCollapse(bool expand)
        {
            foreach (PivotGridGroup group in pivotGrid.Groups)
                foreach (PivotGridFieldBase field in group)
                    field.ExpandedInFieldsGroup = expand;
        }
        protected void buttonExpandAll_Click(object sender, EventArgs e)
        {
            GroupsExpandCollapse(true);
        }
        protected void buttonCollapseAll_Click(object sender, EventArgs e)
        {
            GroupsExpandCollapse(false);
        }

        protected void pivotGrid_CustomUnboundFieldData(object sender, DevExpress.Web.ASPxPivotGrid.CustomFieldDataEventArgs e)
        {
            /*
            if(object.ReferenceEquals(e.Field, pivotGrid.Fields["SalesPerson"]))
                e.Value = string.Format(salesPersonFormat.SelectedItem.Value.ToString(), e.GetListSourceColumnValue("FirstName"), e.GetListSourceColumnValue("LastName"));
            if(object.ReferenceEquals(e.Field, pivotGrid.Fields["OrderAmount"])) {
                double discount = orderAmountRule.SelectedItem.Value.ToString() == "1" ? Convert.ToDouble(e.GetListSourceColumnValue("Discount")) : 0;
                e.Value = Convert.ToDouble(e.GetListSourceColumnValue("UnitPrice")) * Convert.ToDouble(e.GetListSourceColumnValue("Quantity")) * (1 - discount);
            }
             */

        }

        protected void pivotGrid_CustomCellDisplayText(object sender, DevExpress.Web.ASPxPivotGrid.PivotCellDisplayTextEventArgs e)
        {
            /*
            object orderAmount;
            decimal grandTotalOrderAmount;



            // calcular la participacion 
            if (object.ReferenceEquals(e.DataField, pivotGrid.Fields["PivotGridFieldPART_VLR_VENTA"]))
            {
                DevExpress.Web.ASPxPivotGrid.PivotGridField PivotGridFieldPART_VLR_VENTA = pivotGrid.Fields["PivotGridFieldPART_VLR_VENTA"];
                orderAmount = (e.GetCellValue(PivotGridFieldPART_VLR_VENTA));
                if (orderAmount == null) return;

                grandTotalOrderAmount = Convert.ToDecimal(e.GetRowGrandTotal(PivotGridFieldPART_VLR_VENTA));
                if (grandTotalOrderAmount == 0) return;
                decimal perc = Convert.ToDecimal(orderAmount) / grandTotalOrderAmount;

                e.DisplayText = string.Format("{0:p2}", perc);

                orderAmount = null;
                grandTotalOrderAmount = 0;
            }

            // calcular la participacion 
            if (object.ReferenceEquals(e.DataField, pivotGrid.Fields["PivotGridFieldPART_CANTIDAD"]))
            {
                DevExpress.Web.ASPxPivotGrid.PivotGridField PivotGridFieldPART_CANTIDAD = pivotGrid.Fields["PivotGridFieldPART_CANTIDAD"];
                orderAmount = (e.GetCellValue(PivotGridFieldPART_CANTIDAD));
                if (orderAmount == null) return;

                grandTotalOrderAmount = Convert.ToDecimal(e.GetRowGrandTotal(PivotGridFieldPART_CANTIDAD));
                if (grandTotalOrderAmount == 0) return;
                decimal perc = Convert.ToDecimal(orderAmount) / grandTotalOrderAmount;

                e.DisplayText = string.Format("{0:p2}", perc);

                orderAmount = null;
                grandTotalOrderAmount = 0;
            }

            // calcular la participacion 
            if (object.ReferenceEquals(e.DataField, pivotGrid.Fields["PivotGridFieldPART_Profit"]))
            {
                DevExpress.Web.ASPxPivotGrid.PivotGridField PivotGridFieldPART_Profit = pivotGrid.Fields["PivotGridFieldPART_Profit"];
                orderAmount = (e.GetCellValue(PivotGridFieldPART_Profit));
                if (orderAmount == null) return;

                grandTotalOrderAmount = Convert.ToDecimal(e.GetRowGrandTotal(PivotGridFieldPART_Profit));
                if (grandTotalOrderAmount == 0) return;
                decimal perc = Convert.ToDecimal(orderAmount) / grandTotalOrderAmount;

                e.DisplayText = string.Format("{0:p2}", perc);

                orderAmount = null;
                grandTotalOrderAmount = 0;
            }
            */

        }



        protected void ASPxPivotGrid1_CustomCellStyle(object sender, DevExpress.Web.ASPxPivotGrid.PivotCustomCellStyleEventArgs e)
        {
            if (e.ColumnValueType != DevExpress.XtraPivotGrid.PivotGridValueType.Value || e.RowValueType != DevExpress.XtraPivotGrid.PivotGridValueType.Value)
                return;

            if (Convert.ToDecimal(e.Value) < 0)
                e.CellStyle.BackColor = System.Drawing.Color.LightPink;
        }


        #endregion Pivotgrid


        #region Exportador

        void Export(bool saveAs)
        {
            ASPxPivotGridExporter1.OptionsPrint.PrintHeadersOnEveryPage = checkPrintHeadersOnEveryPage.Checked;
            ASPxPivotGridExporter1.OptionsPrint.PrintFilterHeaders = checkPrintFilterHeaders.Checked ? DefaultBoolean.True : DefaultBoolean.False;
            ASPxPivotGridExporter1.OptionsPrint.PrintColumnHeaders = checkPrintColumnHeaders.Checked ? DefaultBoolean.True : DefaultBoolean.False;
            ASPxPivotGridExporter1.OptionsPrint.PrintRowHeaders = checkPrintRowHeaders.Checked ? DefaultBoolean.True : DefaultBoolean.False;
            ASPxPivotGridExporter1.OptionsPrint.PrintDataHeaders = checkPrintDataHeaders.Checked ? DefaultBoolean.True : DefaultBoolean.False;

            //ASPxPivotGridExporter1.Response.Buffer = false;
            //ASPxPivotGridExporter1.Response.AddHeader("Connection", "Keep-Alive");

            string fileName = fileNameToExport;
            switch (listExportFormat.SelectedIndex)
            {
                case 0:
                    ASPxPivotGridExporter1.ExportXlsxToResponse(fileName, DevExpress.XtraPrinting.TextExportMode.Text, saveAs);  // see excel bug custom totals:  http://www.devexpress.com/Support/Center/p/B93134.aspx
                    break;
                case 1:
                    ASPxPivotGridExporter1.ExportCsvToResponse(fileName, saveAs);
                    break;
                case 2:
                    ASPxPivotGridExporter1.ExportHtmlToResponse(fileName, "utf-8", fileNameToExport, true, saveAs);
                    break;
            }
        }

        protected void buttonOpen_Click(object sender, EventArgs e)
        {
            Export(false);
        }
        protected void buttonSaveAs_Click(object sender, EventArgs e)
        {
            Export(true);
        }



        #endregion Exportador


    }
}