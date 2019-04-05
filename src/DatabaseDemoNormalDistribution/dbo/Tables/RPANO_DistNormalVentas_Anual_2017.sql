CREATE TABLE [dbo].[RPANO_DistNormalVentas_Anual_2017] (
    [Rn]            INT        NOT NULL,
    [YAxis]         FLOAT (53) NULL,
    [NormalDist]    FLOAT (53) NULL,
    [Rank]          FLOAT (53) NULL,
    [SUMValorBruto] FLOAT (53) NULL,
    CONSTRAINT [PK_RPANO_DistNormalVentas_Anual_2017] PRIMARY KEY CLUSTERED ([Rn] ASC)
);

