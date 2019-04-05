CREATE TABLE [dbo].[RPANO_DistNormalAcumVentas_Anual_2017] (
    [Fecha]        DATE       NOT NULL,
    [ValorBruto]   FLOAT (53) NULL,
    [DistNormalAc] FLOAT (53) NULL,
    [Rank]         FLOAT (53) NULL,
    CONSTRAINT [PK_RPANO_DistNormalAcumVentas_Anual_2017] PRIMARY KEY CLUSTERED ([Fecha] ASC)
);

