CREATE TABLE [dbo].[RPMES_DistNormalAcumVentas_Mensual_2017_10] (
    [Fecha]        DATE       NOT NULL,
    [ValorBruto]   FLOAT (53) NULL,
    [DistNormalAc] FLOAT (53) NULL,
    [Rank]         FLOAT (53) NULL,
    CONSTRAINT [PK_RPMES_DistNormalAcumVentas_Mensual_2017_10] PRIMARY KEY CLUSTERED ([Fecha] ASC)
);

