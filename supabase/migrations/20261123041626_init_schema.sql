-- Koini: Skema awal 14 tabel (mengacu ERD_Koini.pdf), indeks, RLS, dan fungsi sisa_jajan.

-- ---------------------------------------------------------------------------
-- 1. Skema privat & fungsi utilitas (tidak terekspos di Data API)
-- ---------------------------------------------------------------------------
CREATE SCHEMA IF NOT EXISTS private;

REVOKE ALL ON SCHEMA private FROM PUBLIC, anon, authenticated;
GRANT USAGE ON SCHEMA private TO authenticated;

CREATE OR REPLACE FUNCTION private.set_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path = ''
AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

-- ---------------------------------------------------------------------------
-- 2. Tabel inti keluarga & langganan
-- ---------------------------------------------------------------------------
CREATE TABLE public.orang_tua (
  orang_tua_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  nama VARCHAR(100) NOT NULL,
  pin_diatur BOOLEAN NOT NULL DEFAULT FALSE,
  persetujuan_data_pada TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER orang_tua_set_updated_at
  BEFORE UPDATE ON public.orang_tua
  FOR EACH ROW
  EXECUTE FUNCTION private.set_updated_at();

CREATE TABLE public.anak (
  anak_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  orang_tua_id UUID NOT NULL REFERENCES public.orang_tua(orang_tua_id) ON DELETE CASCADE,
  nama_panggilan VARCHAR(50) NOT NULL,
  usia INT NOT NULL CHECK (usia BETWEEN 6 AND 12),
  avatar VARCHAR(50) NOT NULL DEFAULT 'mascot',
  streak_hari INT NOT NULL DEFAULT 0 CHECK (streak_hari >= 0),
  tutorial_selesai BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX anak_orang_tua_id_idx ON public.anak (orang_tua_id);

CREATE TRIGGER anak_set_updated_at
  BEFORE UPDATE ON public.anak
  FOR EACH ROW
  EXECUTE FUNCTION private.set_updated_at();

-- Helper kepemilikan anak untuk RLS tabel turunan
CREATE OR REPLACE FUNCTION private.is_orang_tua_dari(target_anak_id BIGINT)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.anak a
    WHERE a.anak_id = target_anak_id
      AND a.orang_tua_id = (SELECT auth.uid())
  );
$$;

REVOKE ALL ON FUNCTION private.is_orang_tua_dari(BIGINT) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION private.is_orang_tua_dari(BIGINT) TO authenticated;

CREATE TABLE public.langganan (
  langganan_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  orang_tua_id UUID NOT NULL REFERENCES public.orang_tua(orang_tua_id) ON DELETE CASCADE,
  paket TEXT NOT NULL CHECK (paket IN ('gratis', 'bulanan', 'tahunan')),
  harga INT NOT NULL DEFAULT 0 CHECK (harga >= 0),
  mulai DATE NOT NULL DEFAULT CURRENT_DATE,
  berakhir DATE CHECK (berakhir IS NULL OR berakhir >= mulai),
  status TEXT NOT NULL DEFAULT 'aktif' CHECK (status IN ('aktif', 'berakhir')),
  is_simulasi BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX langganan_orang_tua_id_idx ON public.langganan (orang_tua_id);

-- ---------------------------------------------------------------------------
-- 3. Pengaturan uang saku, impian, buku kas (catatan), dan cek celengan
-- ---------------------------------------------------------------------------
CREATE TABLE public.pengaturan_uang_saku (
  pengaturan_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  anak_id BIGINT NOT NULL REFERENCES public.anak(anak_id) ON DELETE CASCADE,
  nominal INT NOT NULL CHECK (nominal > 0),
  periode TEXT NOT NULL CHECK (periode IN ('harian', 'mingguan', 'bulanan')),
  porsi_tabung INT NOT NULL CHECK (porsi_tabung >= 0),
  porsi_jajan INT NOT NULL CHECK (porsi_jajan >= 0),
  porsi_berbagi INT NOT NULL CHECK (porsi_berbagi >= 0),
  berlaku_mulai DATE NOT NULL DEFAULT CURRENT_DATE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT pengaturan_porsi_total_chk CHECK (
    porsi_tabung + porsi_jajan + porsi_berbagi <= nominal
    AND porsi_tabung + porsi_jajan + porsi_berbagi > 0
  )
);

CREATE INDEX pengaturan_uang_saku_anak_id_idx
  ON public.pengaturan_uang_saku (anak_id, berlaku_mulai DESC);

CREATE TABLE public.impian (
  impian_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  anak_id BIGINT NOT NULL REFERENCES public.anak(anak_id) ON DELETE CASCADE,
  nama VARCHAR(100) NOT NULL,
  gambar VARCHAR(255) NOT NULL,
  target_harga INT NOT NULL CHECK (target_harga > 0),
  is_utama BOOLEAN NOT NULL DEFAULT FALSE,
  status TEXT NOT NULL DEFAULT 'aktif' CHECK (status IN ('aktif', 'tercapai', 'batal')),
  tercapai_pada TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX impian_anak_id_idx ON public.impian (anak_id);
CREATE UNIQUE INDEX impian_satu_utama_aktif_idx
  ON public.impian (anak_id)
  WHERE is_utama = TRUE AND status = 'aktif';

CREATE TRIGGER impian_set_updated_at
  BEFORE UPDATE ON public.impian
  FOR EACH ROW
  EXECUTE FUNCTION private.set_updated_at();

CREATE TABLE public.catatan (
  catatan_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  anak_id BIGINT NOT NULL REFERENCES public.anak(anak_id) ON DELETE CASCADE,
  impian_id BIGINT REFERENCES public.impian(impian_id) ON DELETE SET NULL,
  toples TEXT NOT NULL CHECK (toples IN ('jajan', 'tabung', 'berbagi')),
  jenis TEXT NOT NULL CHECK (jenis IN ('masuk', 'keluar')),
  kategori TEXT NOT NULL CHECK (
    kategori IN (
      'uang_saku',
      'jajan',
      'sumbangan',
      'sisa_jajan',
      'hadiah',
      'tantangan',
      'bonus',
      'lainnya'
    )
  ),
  nominal INT NOT NULL CHECK (nominal > 0),
  keterangan VARCHAR(100) NOT NULL DEFAULT '',
  tanggal DATE NOT NULL DEFAULT CURRENT_DATE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX catatan_anak_id_tanggal_idx ON public.catatan (anak_id, tanggal DESC);
CREATE INDEX catatan_impian_id_idx ON public.catatan (impian_id) WHERE impian_id IS NOT NULL;
CREATE UNIQUE INDEX catatan_sisa_jajan_unik_idx
  ON public.catatan (anak_id, tanggal, toples)
  WHERE kategori = 'sisa_jajan';

CREATE TABLE public.cek_celengan (
  cek_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  anak_id BIGINT NOT NULL REFERENCES public.anak(anak_id) ON DELETE CASCADE,
  jumlah_fisik INT NOT NULL CHECK (jumlah_fisik >= 0),
  jumlah_catatan INT NOT NULL CHECK (jumlah_catatan >= 0),
  selisih INT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX cek_celengan_anak_id_idx ON public.cek_celengan (anak_id, created_at DESC);

-- ---------------------------------------------------------------------------
-- 4. Misi kuis, soal, progres, lencana, dan fitur Koini Plus
-- ---------------------------------------------------------------------------
CREATE TABLE public.misi (
  misi_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  topik TEXT NOT NULL CHECK (
    topik IN (
      'butuh_mau',
      'menabung_bertahap',
      'mengatur_jajan',
      'menahan_keinginan',
      'promo'
    )
  ),
  level INT NOT NULL CHECK (level > 0),
  judul VARCHAR(100) NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (topik, level)
);

CREATE TABLE public.soal (
  soal_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  misi_id BIGINT NOT NULL REFERENCES public.misi(misi_id) ON DELETE CASCADE,
  cerita TEXT NOT NULL,
  opsi_a VARCHAR(150) NOT NULL,
  opsi_b VARCHAR(150) NOT NULL,
  opsi_c VARCHAR(150) NOT NULL,
  opsi_d VARCHAR(150) NOT NULL,
  jawaban TEXT NOT NULL CHECK (jawaban IN ('a', 'b', 'c', 'd')),
  penjelasan_benar TEXT NOT NULL,
  penjelasan_salah TEXT NOT NULL,
  sumber VARCHAR(100) NOT NULL
);

CREATE INDEX soal_misi_id_idx ON public.soal (misi_id);

CREATE TABLE public.progres_misi (
  progres_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  anak_id BIGINT NOT NULL REFERENCES public.anak(anak_id) ON DELETE CASCADE,
  misi_id BIGINT NOT NULL REFERENCES public.misi(misi_id) ON DELETE CASCADE,
  jumlah_benar INT NOT NULL CHECK (jumlah_benar BETWEEN 0 AND 5),
  bintang INT NOT NULL CHECK (bintang >= 0),
  selesai_pada TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (anak_id, misi_id)
);

CREATE INDEX progres_misi_anak_id_idx ON public.progres_misi (anak_id);
CREATE INDEX progres_misi_misi_id_idx ON public.progres_misi (misi_id);

CREATE TABLE public.lencana (
  lencana_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  nama VARCHAR(50) NOT NULL UNIQUE,
  deskripsi VARCHAR(150) NOT NULL,
  ikon VARCHAR(50) NOT NULL,
  syarat VARCHAR(100) NOT NULL
);

CREATE TABLE public.lencana_anak (
  lencana_anak_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  anak_id BIGINT NOT NULL REFERENCES public.anak(anak_id) ON DELETE CASCADE,
  lencana_id BIGINT NOT NULL REFERENCES public.lencana(lencana_id) ON DELETE CASCADE,
  didapat_pada TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (anak_id, lencana_id)
);

CREATE INDEX lencana_anak_anak_id_idx ON public.lencana_anak (anak_id);
CREATE INDEX lencana_anak_lencana_id_idx ON public.lencana_anak (lencana_id);

CREATE TABLE public.tantangan_hadiah (
  tantangan_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  anak_id BIGINT NOT NULL REFERENCES public.anak(anak_id) ON DELETE CASCADE,
  impian_id BIGINT REFERENCES public.impian(impian_id) ON DELETE SET NULL,
  judul VARCHAR(100) NOT NULL,
  jenis TEXT NOT NULL CHECK (jenis IN ('nilai_ujian', 'lomba', 'tugas_rumah', 'lainnya')),
  syarat VARCHAR(150) NOT NULL,
  hadiah INT NOT NULL CHECK (hadiah > 0),
  status TEXT NOT NULL DEFAULT 'berjalan' CHECK (
    status IN ('berjalan', 'menunggu_konfirmasi', 'berhasil', 'gagal')
  ),
  dikonfirmasi_pada TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX tantangan_hadiah_anak_id_idx ON public.tantangan_hadiah (anak_id);
CREATE INDEX tantangan_hadiah_impian_id_idx
  ON public.tantangan_hadiah (impian_id)
  WHERE impian_id IS NOT NULL;

CREATE TABLE public.bonus_tabungan (
  bonus_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  anak_id BIGINT NOT NULL REFERENCES public.anak(anak_id) ON DELETE CASCADE,
  nominal_bonus INT NOT NULL CHECK (nominal_bonus > 0),
  minimal_tabungan INT NOT NULL CHECK (minimal_tabungan > 0),
  mulai DATE NOT NULL DEFAULT CURRENT_DATE,
  berakhir DATE NOT NULL CHECK (berakhir >= mulai),
  status TEXT NOT NULL DEFAULT 'berjalan' CHECK (status IN ('berjalan', 'berhasil', 'gagal')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX bonus_tabungan_anak_id_idx ON public.bonus_tabungan (anak_id);

-- ---------------------------------------------------------------------------
-- 5. Fungsi idempoten sisa_jajan (2 baris: keluar jajan + masuk tabung)
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.sisa_jajan(
  p_anak_id BIGINT,
  p_periode_mulai DATE,
  p_periode_selesai DATE
)
RETURNS INT
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = ''
AS $$
DECLARE
  v_sisa INT := 0;
  v_impian_utama_id BIGINT;
  v_keterangan VARCHAR(100);
BEGIN
  IF p_periode_selesai < p_periode_mulai THEN
    RAISE EXCEPTION 'Tanggal selesai periode tidak boleh sebelum tanggal mulai';
  END IF;

  -- Kunci baris anak agar pemanggilan bersamaan tetap aman; RLS juga membatasi kepemilikan
  PERFORM 1
  FROM public.anak a
  WHERE a.anak_id = p_anak_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Anak tidak ditemukan atau akses ditolak';
  END IF;

  -- Idempoten: jika sisa jajan untuk akhir periode ini sudah pernah dicatat, hentikan
  IF EXISTS (
    SELECT 1
    FROM public.catatan c
    WHERE c.anak_id = p_anak_id
      AND c.kategori = 'sisa_jajan'
      AND c.tanggal = p_periode_selesai
  ) THEN
    RETURN 0;
  END IF;

  -- Hitung saldo toples jajan sampai akhir periode yang ditutup
  SELECT COALESCE(
    SUM(CASE WHEN c.jenis = 'masuk' THEN c.nominal ELSE -c.nominal END),
    0
  )::INT
  INTO v_sisa
  FROM public.catatan c
  WHERE c.anak_id = p_anak_id
    AND c.toples = 'jajan'
    AND c.tanggal <= p_periode_selesai;

  IF v_sisa <= 0 THEN
    RETURN 0;
  END IF;

  -- Hubungkan otomatis ke impian utama aktif (jika ada)
  SELECT i.impian_id
  INTO v_impian_utama_id
  FROM public.impian i
  WHERE i.anak_id = p_anak_id
    AND i.is_utama = TRUE
    AND i.status = 'aktif'
  LIMIT 1;

  v_keterangan := LEFT(
    'Sisa jajan periode ' || TO_CHAR(p_periode_mulai, 'YYYY-MM-DD') ||
    ' s.d. ' || TO_CHAR(p_periode_selesai, 'YYYY-MM-DD'),
    100
  );

  -- Catat 2 baris dalam satu transaksi: keluar jajan + masuk tabung
  INSERT INTO public.catatan (
    anak_id,
    impian_id,
    toples,
    jenis,
    kategori,
    nominal,
    keterangan,
    tanggal
  )
  VALUES
    (
      p_anak_id,
      NULL,
      'jajan',
      'keluar',
      'sisa_jajan',
      v_sisa,
      v_keterangan,
      p_periode_selesai
    ),
    (
      p_anak_id,
      v_impian_utama_id,
      'tabung',
      'masuk',
      'sisa_jajan',
      v_sisa,
      v_keterangan,
      p_periode_selesai
    );

  RETURN v_sisa;
END;
$$;

REVOKE ALL ON FUNCTION public.sisa_jajan(BIGINT, DATE, DATE) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.sisa_jajan(BIGINT, DATE, DATE) TO authenticated;

-- ---------------------------------------------------------------------------
-- 6. Hak akses minimal (least privilege) & Row Level Security (14 tabel)
-- ---------------------------------------------------------------------------
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC, anon;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM PUBLIC, anon;

GRANT USAGE ON SCHEMA public TO authenticated;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO authenticated;

GRANT SELECT, INSERT, UPDATE ON public.orang_tua TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.anak TO authenticated;
GRANT SELECT, INSERT, UPDATE ON public.langganan TO authenticated;
GRANT SELECT, INSERT ON public.pengaturan_uang_saku TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.impian TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.catatan TO authenticated;
GRANT SELECT, INSERT ON public.cek_celengan TO authenticated;
GRANT SELECT ON public.misi, public.soal, public.lencana TO authenticated;
GRANT SELECT, INSERT, UPDATE ON public.progres_misi TO authenticated;
GRANT SELECT, INSERT ON public.lencana_anak TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.tantangan_hadiah TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.bonus_tabungan TO authenticated;

ALTER TABLE public.orang_tua ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.anak ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.langganan ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pengaturan_uang_saku ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.impian ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.catatan ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cek_celengan ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.misi ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.soal ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.progres_misi ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lencana ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lencana_anak ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tantangan_hadiah ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bonus_tabungan ENABLE ROW LEVEL SECURITY;

-- orang_tua: orang_tua_id = auth.uid()
CREATE POLICY orang_tua_select_own ON public.orang_tua
  FOR SELECT TO authenticated
  USING (orang_tua_id = (SELECT auth.uid()));

CREATE POLICY orang_tua_insert_own ON public.orang_tua
  FOR INSERT TO authenticated
  WITH CHECK (orang_tua_id = (SELECT auth.uid()));

CREATE POLICY orang_tua_update_own ON public.orang_tua
  FOR UPDATE TO authenticated
  USING (orang_tua_id = (SELECT auth.uid()))
  WITH CHECK (orang_tua_id = (SELECT auth.uid()));

-- anak: orang_tua_id = auth.uid()
CREATE POLICY anak_select_own ON public.anak
  FOR SELECT TO authenticated
  USING (orang_tua_id = (SELECT auth.uid()));

CREATE POLICY anak_insert_own ON public.anak
  FOR INSERT TO authenticated
  WITH CHECK (orang_tua_id = (SELECT auth.uid()));

CREATE POLICY anak_update_own ON public.anak
  FOR UPDATE TO authenticated
  USING (orang_tua_id = (SELECT auth.uid()))
  WITH CHECK (orang_tua_id = (SELECT auth.uid()));

CREATE POLICY anak_delete_own ON public.anak
  FOR DELETE TO authenticated
  USING (orang_tua_id = (SELECT auth.uid()));

-- langganan: orang_tua_id = auth.uid()
CREATE POLICY langganan_select_own ON public.langganan
  FOR SELECT TO authenticated
  USING (orang_tua_id = (SELECT auth.uid()));

CREATE POLICY langganan_insert_own ON public.langganan
  FOR INSERT TO authenticated
  WITH CHECK (orang_tua_id = (SELECT auth.uid()));

CREATE POLICY langganan_update_own ON public.langganan
  FOR UPDATE TO authenticated
  USING (orang_tua_id = (SELECT auth.uid()))
  WITH CHECK (orang_tua_id = (SELECT auth.uid()));

-- pengaturan_uang_saku (append-only): is_orang_tua_dari(anak_id)
CREATE POLICY pengaturan_uang_saku_select_own ON public.pengaturan_uang_saku
  FOR SELECT TO authenticated
  USING ((SELECT private.is_orang_tua_dari(anak_id)));

CREATE POLICY pengaturan_uang_saku_insert_own ON public.pengaturan_uang_saku
  FOR INSERT TO authenticated
  WITH CHECK ((SELECT private.is_orang_tua_dari(anak_id)));

-- impian: is_orang_tua_dari(anak_id)
CREATE POLICY impian_select_own ON public.impian
  FOR SELECT TO authenticated
  USING ((SELECT private.is_orang_tua_dari(anak_id)));

CREATE POLICY impian_insert_own ON public.impian
  FOR INSERT TO authenticated
  WITH CHECK ((SELECT private.is_orang_tua_dari(anak_id)));

CREATE POLICY impian_update_own ON public.impian
  FOR UPDATE TO authenticated
  USING ((SELECT private.is_orang_tua_dari(anak_id)))
  WITH CHECK ((SELECT private.is_orang_tua_dari(anak_id)));

CREATE POLICY impian_delete_own ON public.impian
  FOR DELETE TO authenticated
  USING ((SELECT private.is_orang_tua_dari(anak_id)));

-- catatan: is_orang_tua_dari(anak_id) + pastikan impian_id milik anak yang sama
CREATE POLICY catatan_select_own ON public.catatan
  FOR SELECT TO authenticated
  USING ((SELECT private.is_orang_tua_dari(anak_id)));

CREATE POLICY catatan_insert_own ON public.catatan
  FOR INSERT TO authenticated
  WITH CHECK (
    (SELECT private.is_orang_tua_dari(anak_id))
    AND (
      impian_id IS NULL
      OR EXISTS (
        SELECT 1
        FROM public.impian i
        WHERE i.impian_id = catatan.impian_id
          AND i.anak_id = catatan.anak_id
      )
    )
  );

CREATE POLICY catatan_update_own ON public.catatan
  FOR UPDATE TO authenticated
  USING ((SELECT private.is_orang_tua_dari(anak_id)))
  WITH CHECK (
    (SELECT private.is_orang_tua_dari(anak_id))
    AND (
      impian_id IS NULL
      OR EXISTS (
        SELECT 1
        FROM public.impian i
        WHERE i.impian_id = catatan.impian_id
          AND i.anak_id = catatan.anak_id
      )
    )
  );

CREATE POLICY catatan_delete_own ON public.catatan
  FOR DELETE TO authenticated
  USING ((SELECT private.is_orang_tua_dari(anak_id)));

-- cek_celengan: is_orang_tua_dari(anak_id)
CREATE POLICY cek_celengan_select_own ON public.cek_celengan
  FOR SELECT TO authenticated
  USING ((SELECT private.is_orang_tua_dari(anak_id)));

CREATE POLICY cek_celengan_insert_own ON public.cek_celengan
  FOR INSERT TO authenticated
  WITH CHECK ((SELECT private.is_orang_tua_dari(anak_id)));

-- progres_misi: is_orang_tua_dari(anak_id)
CREATE POLICY progres_misi_select_own ON public.progres_misi
  FOR SELECT TO authenticated
  USING ((SELECT private.is_orang_tua_dari(anak_id)));

CREATE POLICY progres_misi_insert_own ON public.progres_misi
  FOR INSERT TO authenticated
  WITH CHECK ((SELECT private.is_orang_tua_dari(anak_id)));

CREATE POLICY progres_misi_update_own ON public.progres_misi
  FOR UPDATE TO authenticated
  USING ((SELECT private.is_orang_tua_dari(anak_id)))
  WITH CHECK ((SELECT private.is_orang_tua_dari(anak_id)));

-- lencana_anak: is_orang_tua_dari(anak_id)
CREATE POLICY lencana_anak_select_own ON public.lencana_anak
  FOR SELECT TO authenticated
  USING ((SELECT private.is_orang_tua_dari(anak_id)));

CREATE POLICY lencana_anak_insert_own ON public.lencana_anak
  FOR INSERT TO authenticated
  WITH CHECK ((SELECT private.is_orang_tua_dari(anak_id)));

-- tantangan_hadiah: is_orang_tua_dari(anak_id) + pastikan impian_id milik anak yang sama
CREATE POLICY tantangan_hadiah_select_own ON public.tantangan_hadiah
  FOR SELECT TO authenticated
  USING ((SELECT private.is_orang_tua_dari(anak_id)));

CREATE POLICY tantangan_hadiah_insert_own ON public.tantangan_hadiah
  FOR INSERT TO authenticated
  WITH CHECK (
    (SELECT private.is_orang_tua_dari(anak_id))
    AND (
      impian_id IS NULL
      OR EXISTS (
        SELECT 1
        FROM public.impian i
        WHERE i.impian_id = tantangan_hadiah.impian_id
          AND i.anak_id = tantangan_hadiah.anak_id
      )
    )
  );

CREATE POLICY tantangan_hadiah_update_own ON public.tantangan_hadiah
  FOR UPDATE TO authenticated
  USING ((SELECT private.is_orang_tua_dari(anak_id)))
  WITH CHECK (
    (SELECT private.is_orang_tua_dari(anak_id))
    AND (
      impian_id IS NULL
      OR EXISTS (
        SELECT 1
        FROM public.impian i
        WHERE i.impian_id = tantangan_hadiah.impian_id
          AND i.anak_id = tantangan_hadiah.anak_id
      )
    )
  );

CREATE POLICY tantangan_hadiah_delete_own ON public.tantangan_hadiah
  FOR DELETE TO authenticated
  USING ((SELECT private.is_orang_tua_dari(anak_id)));

-- bonus_tabungan: is_orang_tua_dari(anak_id)
CREATE POLICY bonus_tabungan_select_own ON public.bonus_tabungan
  FOR SELECT TO authenticated
  USING ((SELECT private.is_orang_tua_dari(anak_id)));

CREATE POLICY bonus_tabungan_insert_own ON public.bonus_tabungan
  FOR INSERT TO authenticated
  WITH CHECK ((SELECT private.is_orang_tua_dari(anak_id)));

CREATE POLICY bonus_tabungan_update_own ON public.bonus_tabungan
  FOR UPDATE TO authenticated
  USING ((SELECT private.is_orang_tua_dari(anak_id)))
  WITH CHECK ((SELECT private.is_orang_tua_dari(anak_id)));

CREATE POLICY bonus_tabungan_delete_own ON public.bonus_tabungan
  FOR DELETE TO authenticated
  USING ((SELECT private.is_orang_tua_dari(anak_id)));

-- Tabel referensi baca-saja untuk pengguna masuk: misi, soal, lencana
CREATE POLICY misi_select_authenticated ON public.misi
  FOR SELECT TO authenticated
  USING (TRUE);

CREATE POLICY soal_select_authenticated ON public.soal
  FOR SELECT TO authenticated
  USING (TRUE);

CREATE POLICY lencana_select_authenticated ON public.lencana
  FOR SELECT TO authenticated
  USING (TRUE);
