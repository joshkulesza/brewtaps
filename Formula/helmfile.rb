class Helmfile < Formula
  desc "Deploy Kubernetes Helm Charts"
  homepage "https://github.com/roboll/helmfile"
  url "https://github.com/roboll/helmfile/archive/v0.118.4.tar.gz"
  sha256 "98a77a8cb859e6d3596d989047115d699010d141723dd8c50614260fc9a39552"

  bottle do
    cellar :any_skip_relocation
    sha256 "dda7353304e661eec7913804fe89eb9e48e4c2f66af55f27adfa966ec3d180c9" => :catalina
    sha256 "748e3768922c7e6fc38a18e7c02e307fe8e0bde5f824863c6ce1f00a6cb50741" => :mojave
    sha256 "8ace20c36ca0206e400464a000197663329e8dcd2f7acc07b98d149894f45392" => :high_sierra
  end

  depends_on "go" => :build
  depends_on "joshkulesza/tap/helm"

  def install
    system "go", "build", "-ldflags", "-X github.com/roboll/helmfile/pkg/app/version.Version=v#{version}",
             "-o", bin/"helmfile", "-v", "github.com/roboll/helmfile"
  end

  test do
    (testpath/"helmfile.yaml").write <<-EOS
    repositories:
    - name: stable
      url: https://kubernetes-charts.storage.googleapis.com/

    releases:
    - name: vault                            # name of this release
      namespace: vault                       # target namespace
      labels:                                # Arbitrary key value pairs for filtering releases
        foo: bar
      chart: roboll/vault-secret-manager     # the chart being installed to create this release, referenced by `repository/chart` syntax
      version: ~1.24.1                       # the semver of the chart. range constraint is supported
    EOS
    system Formula["helm"].opt_bin/"helm", "create", "foo"
    output = "Adding repo stable https://kubernetes-charts.storage.googleapis.com"
    assert_match output, shell_output("#{bin}/helmfile -f helmfile.yaml repos 2>&1")
    assert_match version.to_s, shell_output("#{bin}/helmfile -v")
  end
end
