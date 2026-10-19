-- ============================================================
-- HoopsTrack — Script SQL para Supabase
-- Execute no SQL Editor do seu projeto Supabase
-- ============================================================

-- 1. Criar a tabela principal de treinos de basquete
CREATE TABLE IF NOT EXISTS public.basketball_workouts (
  id               UUID           DEFAULT gen_random_uuid() PRIMARY KEY,
  title            VARCHAR(120)   NOT NULL,
  category         VARCHAR(50)    NOT NULL
    CHECK (category IN ('Ball-Handling', 'Arremesso', 'Salto / Plyo', 'Musculação', 'Jogo / Coletivo')),
  metrics_type     VARCHAR(50)    NOT NULL DEFAULT 'Repetições',
  volume_target    INTEGER        DEFAULT 0,
  volume_completed INTEGER        DEFAULT 0,
  duration_minutes INTEGER        NOT NULL CHECK (duration_minutes > 0),
  intensity_rpe    INTEGER        CHECK (intensity_rpe BETWEEN 1 AND 10),
  notes            TEXT,
  completed        BOOLEAN        DEFAULT FALSE,
  created_at       TIMESTAMPTZ    DEFAULT NOW() NOT NULL,
  updated_at       TIMESTAMPTZ    DEFAULT NOW() NOT NULL
);

-- 2. Índice para ordenação por data (DESC) — performance em listagens
CREATE INDEX IF NOT EXISTS idx_workouts_created_at
  ON public.basketball_workouts (created_at DESC);

-- 3. Habilitar Row Level Security
ALTER TABLE public.basketball_workouts ENABLE ROW LEVEL SECURITY;

-- 4. Política pública de acesso total (prototipagem / anon key)
CREATE POLICY "Acesso total público"
  ON public.basketball_workouts
  FOR ALL
  USING (true)
  WITH CHECK (true);

-- 5. Trigger para atualizar updated_at automaticamente
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER set_updated_at
  BEFORE UPDATE ON public.basketball_workouts
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_updated_at();
