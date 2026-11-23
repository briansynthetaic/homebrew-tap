class ConceptGraph < Formula
  desc "Explore agent-generated concept maps in a native macOS window"
  homepage "https://github.com/briansynthetaic/agent-concept-graph"
  url "https://github.com/briansynthetaic/agent-concept-graph.git",
      tag: "v0.2.6", revision: "2e1552569431ac5dff1a7f6d5d196439242e25f3"

  depends_on macos: :sonoma

  def install
    system "./scripts/build.sh"
    libexec.install "skill"
    wrapper = buildpath/"scripts/homebrew-cli"
    inreplace wrapper, "@CONCEPT_GRAPH_SKILL@", "#{opt_libexec}/skill"
    bin.install wrapper => "concept-graph"
    chmod 0755, bin/"concept-graph"
  end

  def caveats
    <<~EOS
      Connect Concept Graph to your agent by running its command in Terminal:
        concept-graph link claude
        concept-graph link codex

      If you use both agents, run both commands. For another agent that supports
      linked skill folders, use: concept-graph link --dir "/path/to/skills"

      In your agent chat, ask "map this conversation to a concept-graph."
      For future updates, run brew install concept-graph
    EOS
  end

  test do
    system bin/"concept-graph", "link", "--dir", testpath/"skills"
    assert_equal (opt_libexec/"skill").to_s, (testpath/"skills/concept-graph").readlink.to_s
    system bin/"concept-graph", "validate", testpath/"skills/concept-graph/examples/conversation.json"
    system bin/"concept-graph", "unlink", "--dir", testpath/"skills"
    refute_predicate testpath/"skills/concept-graph", :symlink?
  end
end
